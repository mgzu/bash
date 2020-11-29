# oracle 配置及处理脚本
> 未特殊标注，均使用 oracle 默认安装路径及 oracle 19c（一般兼容 *c）

## install_oracle_and_configure.sh
oracle 安装及初始化配置

* 修改默认字符集为 GBK
* 自动安装 oracle（可能会出现错误，需要另外处理）
* 自动修改为随机密码
* 自动添加默认 pdb
