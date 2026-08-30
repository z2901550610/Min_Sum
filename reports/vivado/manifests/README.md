# Vivado运行清单

每次新Vivado运行在本目录提交一个`RUN-YYYYMMDD-NN-<top>.toml`。原始`.rpt`和`.dcp`
保存在`${VIVADO_REPORT_ROOT}/<run-id>/`，不复制进Git。报告根目录通过 Windows Tcl
环境、`config/vivado_local.tcl`或可选的`config/local.mk`配置；历史 manifest 保留
该次运行实际使用的绝对路径。

1. 复制`template.toml.example`并更名为唯一run ID。
2. 从外部run目录的`run_provenance.txt`填写Git revision、dirty状态、filelist、defines、XDC和directive；
   dirty运行必须在`notes`中说明变更边界。
3. 只填写报告真实给出的数字；缺失值使用空字符串，不估算。
4. 运行`make check-records`验证ID、状态、必填字段和文件名。
5. 只有同条件、Fully Routed且被采用的结果才能进入基线注册表。
