`timescale 1ns / 1ps

module tb_trike_pseudohash512_runtime;
  localparam int MAX_MESSAGE_BYTES = 127;

  logic           clk;
  logic           rst_n;
  logic           start;
  logic   [ 31:0] runtime_message_bytes;
  logic           input_valid;
  logic   [  7:0] input_data;
  logic           input_ready;
  logic           input_pass;
  logic           busy;
  logic           done;
  logic   [511:0] digest;
  integer         input_idx;
  integer         busy_cycles;

  assign input_data = 8'((7 * input_idx) + 3);

  trike_pseudohash512_stream #(
      .MESSAGE_BYTES (MAX_MESSAGE_BYTES),
      .RUNTIME_LENGTH(1'b1)
  ) dut (
      .i_clk                  (clk),
      .i_rst_n                (rst_n),
      .i_start                (start),
      .i_runtime_message_bytes(runtime_message_bytes),
      .i_input_valid          (input_valid),
      .i_input_data           (input_data),
      .o_input_ready          (input_ready),
      .o_input_pass           (input_pass),
      .o_busy                 (busy),
      .o_done                 (done),
      .o_digest               (digest),
      .o_compress_start       (),
      .o_compress_block       (),
      .o_compress_state       (),
      .i_compress_busy        (1'b0),
      .i_compress_done        (1'b0),
      .i_compress_state       ('0)
  );

  function automatic logic [511:0] expected_digest(input integer message_bytes);
    begin
      unique case (message_bytes)
        1:
        expected_digest = 512'h066f9c530bceac1a4faf5c5d65dee038f3338041abea2071541b5c9498281d941ffa25caa135f9d4546527a39c461957eb962cb9c7b4d147a50ca8520af53704;
        55:
        expected_digest = 512'h031429f84a8ccd6d6cfdb0057e5622b6bd066d1ef1d67ec8bbaecb3cd6a074e31ab36d8a8291f41ed8bcffee03fff877e2c2bf3f403772c649c70ced66ce75d5;
        56:
        expected_digest = 512'h338877e9d4e3b4c18c1783b1e70ed4e4a465ef4fbdc1dfeaf81f70491ab92c1cd3311d21c1c54a1979e16b586e716051c4ca9ecb848db062147c41fe70647e6a;
        64:
        expected_digest = 512'h6ce9675765745e42fcb2f2db21139ffebf9339d225dca939f9b129dbdf913960faeea5a5d92e7b7b5051e5363823d1bcb11684ee845f2556c740db6cb61d96c7;
        65:
        expected_digest = 512'h3a48383366e858660c9eb3709dbb0f3693d1a42199edf5e0bc12375f36f3e6dd0b1a0e64945346513ab13afded98a471851aeaea6dd4c3872a9facb3fc322c11;
        default:
        expected_digest = 512'hb97be7c4b793311567fc293dd3c74acc28b88dc286ea0973c95d941a119a168366218be6d3c8de8c56627860c8199603dbd0de7b8f988e439e3f84578394a610;
      endcase
    end
  endfunction

  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) busy_cycles <= 0;
    else if (start) busy_cycles <= 0;
    else if (busy) busy_cycles <= busy_cycles + 1;
  end

  task automatic run_case(input integer message_bytes);
    begin
      @(negedge clk);
      runtime_message_bytes = 32'(message_bytes);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      runtime_message_bytes = 32'(MAX_MESSAGE_BYTES);
      input_valid = 1'b1;
      for (int pass = 0; pass < 2; pass++) begin
        input_idx = 0;
        while (input_idx < message_bytes) begin
          @(posedge clk);
          if (input_ready) begin
            if (input_pass != pass[0]) $fatal(1, "runtime pseudohash pass mismatch");
            @(negedge clk);
            input_idx++;
          end
        end
      end
      input_valid = 1'b0;
      while (!done) @(negedge clk);
      if (digest != expected_digest(message_bytes))
        $fatal(1, "runtime pseudohash digest mismatch for length %0d", message_bytes);
      $display("runtime pseudohash bytes=%0d cycles=%0d", message_bytes, busy_cycles);
    end
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_message_bytes = '0;
    input_valid = 1'b0;
    input_idx = 0;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    run_case(1);
    run_case(55);
    run_case(56);
    run_case(64);
    run_case(65);
    run_case(127);
    $display("tb_trike_pseudohash512_runtime PASS");
    $finish;
  end

endmodule
