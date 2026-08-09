# Vivado运行清单

每次新Vivado运行在本目录提交一个`RUN-YYYYMMDD-NN-<top>.toml`。原始`.rpt`和`.dcp`
保存在`D:/trike_reports/<run-id>/`，不复制进Git。

1. 复制`template.toml.example`并更名为唯一run ID。
2. 填写Git revision和dirty状态；dirty运行必须在`notes`中说明变更边界。
3. 只填写报告真实给出的数字；缺失值使用空字符串，不估算。
4. 运行`make check-records`验证ID、状态、必填字段和文件名。
5. 只有同条件、Fully Routed且被采用的结果才能进入基线注册表。
