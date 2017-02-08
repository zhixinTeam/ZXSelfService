delete from sys_dict where d_name='aicmworkshop';
insert into sys_dict(d_name,d_desc,d_value,d_memo,d_paramA,d_paramb,d_index)
select 'aicmworkshop' as d_name,'B' as d_desc,d_value,'一车间' as d_memo,0 as d_paramA,d_paramb,d_index 
from sys_dict where d_name='StockItem';

delete from sys_datadict where d_entity like '%MAIN_A08';
insert into sys_datadict(d_entity,d_title,d_width,d_index,d_dbfield,d_dbiskey,d_align,d_visible)
values('ZXSOFT_MAIN_A08','水泥编号',133,0,'d_paramb',-1,0,-1);
insert into sys_datadict(d_entity,d_title,d_width,d_index,d_dbfield,d_dbiskey,d_align,d_visible)
values('ZXSOFT_MAIN_A08','水泥名称',133,1,'d_value',0,0,-1);
insert into sys_datadict(d_entity,d_title,d_width,d_index,d_dbfield,d_dbiskey,d_align,d_visible)
values('ZXSOFT_MAIN_A08','车间名称',133,3,'d_memo',0,0,-1);
insert into sys_datadict(d_entity,d_title,d_width,d_index,d_dbfield,d_dbiskey,d_align,d_visible)
values('ZXSOFT_MAIN_A08','车间代码',133,2,'d_desc',0,0,-1);