# E5-01 分类删除限制 —— 变更影响分析

学号 20244350112（姓名已做隐私化处理）

## 作品文件

| 文件 | 说明 |
|---|---|
| `E5-一页说明-20244350112.md` | 一页说明（讲清楚/有依据/验证过） |
| `E5-发言稿-20244350112.md` | 2 分钟录屏发言稿 |
| `PmsProductCategoryServiceImpl.java` | 当前源码（delete 无校验，:105-107） |
| `evidence/1_categories_with_children.log` | 有子分类的分类（受控查询证据） |
| `evidence/2_categories_with_products.log` | 有商品的分类（受控查询证据） |
| `evidence/3_controlled_delete.log` | 受控删除（deleted_rows=1，证明无校验） |
| `evidence/4_table_ddl.log` | 表 DDL（证明无外键约束） |
| `evidence/5_delete_source.log` | 源码定位（deleteByPrimaryKey 无校验） |
| `run_e5-01.bat` | 一键运行脚本 |

## 证据链接

- 受控删除证据：`evidence/3_controlled_delete.log`
- 无外键证据：`evidence/4_table_ddl.log`

## 变更摘要

分类删除 `PmsProductCategoryServiceImpl.delete`（:105-107）当前无校验，会删除仍有子分类/商品的分类。
本次只做影响分析与回归计划，不实现新需求（留给 E6 逐项对照）。详见一页说明。
