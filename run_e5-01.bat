@echo off
setlocal

REM ============================================================
REM  E5-01 category delete restriction - evidence runner
REM  Runs controlled SQL checks to prove the defect exists:
REM    1. categories that have children
REM    2. categories that have products
REM    3. controlled delete (rollback) proving no guard
REM    4. table has no foreign key constraint
REM ============================================================

set "MYSQL=C:\Program Files\MySQL\MySQL Server 9.2\bin\mysql.exe"
set "PROJECT=C:\Users\root\Downloads\mall-master\mall-master"

if not exist "%MYSQL%" set "MYSQL=mysql"

set "EV=%PROJECT%\evidence-e5"
if exist "%EV%" rmdir /s /q "%EV%"
mkdir "%EV%"

echo ============================================================
echo  [1/5] categories that have children
echo ============================================================
"%MYSQL%" -uroot -pcaoqiong1 -e "SELECT parent_id, COUNT(*) AS child_cnt FROM mall.pms_product_category WHERE parent_id>0 GROUP BY parent_id HAVING child_cnt>0 LIMIT 10;" > "%EV%\1_categories_with_children.log" 2>&1
echo done -> evidence-e5\1_categories_with_children.log

echo.
echo ============================================================
echo  [2/5] categories that have products
echo ============================================================
"%MYSQL%" -uroot -pcaoqiong1 -e "SELECT product_category_id, COUNT(*) AS product_cnt FROM mall.pms_product GROUP BY product_category_id HAVING product_cnt>0 LIMIT 10;" > "%EV%\2_categories_with_products.log" 2>&1
echo done -> evidence-e5\2_categories_with_products.log

echo.
echo ============================================================
echo  [3/5] controlled delete (rollback) - proves no guard
echo ============================================================
(
echo START TRANSACTION;
echo SELECT id, name, parent_id FROM mall.pms_product_category WHERE id=1;
echo DELETE FROM mall.pms_product_category WHERE id=1;
echo SELECT ROW_COUNT^(^) AS deleted_rows;
echo ROLLBACK;
echo SELECT id, name, parent_id FROM mall.pms_product_category WHERE id=1;
) > "%EV%\3_controlled_delete.sql"
"%MYSQL%" -uroot -pcaoqiong1 < "%EV%\3_controlled_delete.sql" > "%EV%\3_controlled_delete.log" 2>&1
echo done -> evidence-e5\3_controlled_delete.log

echo.
echo ============================================================
echo  [4/5] no foreign key constraint
echo ============================================================
"%MYSQL%" -uroot -pcaoqiong1 -e "SHOW CREATE TABLE mall.pms_product_category\G" > "%EV%\4_table_ddl.log" 2>&1
echo done -> evidence-e5\4_table_ddl.log

echo.
echo ============================================================
echo  [5/5] source: delete has no guard
echo ============================================================
findstr /n "deleteByPrimaryKey" "%PROJECT%\mall-admin\src\main\java\com\macro\mall\service\impl\PmsProductCategoryServiceImpl.java" > "%EV%\5_delete_source.log" 2>&1
echo done -> evidence-e5\5_delete_source.log

echo.
echo ============================================================
echo  Summary
echo ============================================================
echo  Evidence files in: %EV%
echo   1_categories_with_children.log
echo   2_categories_with_products.log
echo   3_controlled_delete.log   (deleted_rows=1 proves no guard)
echo   4_table_ddl.log           (no FOREIGN KEY)
echo   5_delete_source.log       (delete is deleteByPrimaryKey only)
echo ============================================================

pause
endlocal
