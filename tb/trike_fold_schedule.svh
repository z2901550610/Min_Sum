// Closed-form producer/folder overlap budget; no DUT state references.
// Include inside a test module. Each next diagonal needs length+1 operand
// cycles; the previous folded word occupies 2 cycles per RMW plus advance.
function automatic integer trike_fold_overlap_savings(input integer r, input integer word_w);
  integer n, h, saved, writes, shifted, next_length, fold_service;
  begin
    n = (r + word_w - 1) / word_w;
    h = (n + 1) / 2;
    saved = 0;
    for (integer phase = 0; phase < 3; phase++) begin
      for (integer k = 0; k < 2 * h - 2; k++) begin
        writes = 0;
        for (integer term_idx = 0; term_idx < ((phase == 2) ? 1 : 2); term_idx++) begin
          shifted = k + (((phase == 2) || (term_idx == 1)) ? h : phase * 2 * h);
          writes++;
          if ((r % word_w != 0) && (shifted >= n - 1) && (shifted <= 2 * n - 2)) writes++;
        end
        next_length  = (k + 1 < h) ? k + 2 : 2 * h - 2 - k;
        fold_service = 2 * writes + 1;
        saved += (next_length + 1 < fold_service) ? next_length + 1 : fold_service;
      end
    end
    return saved;
  end
endfunction
