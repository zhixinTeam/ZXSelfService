{*******************************************************************************
  ����: dmzn@163.com 2008-08-07
  ����: ϵͳ���ݿⳣ������

  ��ע:
  *.�Զ�����SQL���,֧�ֱ���:$Inc,����;$Float,����;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,��������
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

  cPrecision            = 100;
  {-----------------------------------------------------------------------------
   ����: ���㾫��
   *.����Ϊ�ֵļ�����,С��ֵ�Ƚϻ����������ʱ�������,���Ի��ȷŴ�,ȥ��
     С��λ������������.�Ŵ����ɾ���ֵȷ��.
  -----------------------------------------------------------------------------}

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //ϵͳ����

var
  gSysTableList: TList = nil;                        //ϵͳ������
  gSysDBType: TSysDatabaseType = dtSQLServer;        //ϵͳ��������

//------------------------------------------------------------------------------
const
  //�����ֶ�
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //С���ֶ�
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //ͼƬ�ֶ�
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //�������
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*Ȩ����*}
  sPopedom_Read       = 'A';                         //���
  sPopedom_Add        = 'B';                         //����
  sPopedom_Edit       = 'C';                         //�޸�
  sPopedom_Delete     = 'D';                         //ɾ��
  sPopedom_Preview    = 'E';                         //Ԥ��
  sPopedom_Print      = 'F';                         //��ӡ
  sPopedom_Export     = 'G';                         //����
  sPopedom_ViewPrice  = 'H';                         //�鿴����

  {*���ݿ��ʶ*}
  sFlag_DB_K3         = 'King_K3';                   //������ݿ�
  sFlag_DB_NC         = 'YonYou_NC';                 //�������ݿ�
  sFlag_DB_YT         = 'YT_GZB';                    //�������ݿ�

  {*��ر��*}
  sFlag_Yes           = 'Y';                         //��
  sFlag_No            = 'N';                         //��
  sFlag_Unknow        = 'U';                         //δ֪ 
  sFlag_Enabled       = 'Y';                         //����
  sFlag_Disabled      = 'N';                         //����

  sFlag_Integer       = 'I';                         //����
  sFlag_Decimal       = 'D';                         //С��

  sFlag_ManualNo      = '%';                         //�ֶ�ָ��(��ϵͳ�Զ�)
  sFlag_NotMatter     = '@';                         //�޹ر��(�����Ŷ���)
  sFlag_ForceDone     = '#';                         //ǿ�����(δ���ǰ����)
  sFlag_FixedNo       = '$';                         //ָ�����(ʹ����ͬ���)

  sFlag_Provide       = 'P';                         //��Ӧ
  sFlag_Sale          = 'S';                         //����
  sFlag_Returns       = 'R';                         //�˻�
  sFlag_DuanDao       = 'D';                         //�̵�(First=>Second)
  sFlag_Other         = 'O';                         //����
  sFlag_HYSale        = 'H';                         //���������
  
  sFlag_TiHuo         = 'T';                         //����
  sFlag_SongH         = 'S';                         //�ͻ�
  sFlag_XieH          = 'X';                         //��ж

  sFlag_Dai           = 'D';                         //��װˮ��
  sFlag_San           = 'S';                         //ɢװˮ��

  sFlag_BillNew       = 'N';                         //�µ�
  sFlag_BillEdit      = 'E';                         //�޸�
  sFlag_BillDel       = 'D';                         //ɾ��
  sFlag_BillLading    = 'L';                         //�����
  sFlag_BillPick      = 'P';                         //����
  sFlag_BillPost      = 'G';                         //����
  sFlag_BillDone      = 'O';                         //���

  sFlag_OrderNew       = 'N';                        //�µ�
  sFlag_OrderEdit      = 'E';                        //�޸�
  sFlag_OrderDel       = 'D';                        //ɾ��
  sFlag_OrderPuring    = 'L';                        //�ͻ���
  sFlag_OrderDone      = 'O';                        //���
  sFlag_OrderAbort     = 'A';                        //����
  sFlag_OrderStop      = 'S';                        //��ֹ

  sFlag_OrderCardL     = 'L';                        //��ʱ
  sFlag_OrderCardG     = 'G';                        //�̶�

  sFlag_TypeShip      = 'S';                         //����
  sFlag_TypeZT        = 'Z';                         //ջ̨
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //��ͨ,��������

  sFlag_CardIdle      = 'I';                         //���п�
  sFlag_CardUsed      = 'U';                         //ʹ����
  sFlag_CardLoss      = 'L';                         //��ʧ��
  sFlag_CardInvalid   = 'N';                         //ע����

  sFlag_TruckNone     = 'N';                         //��״̬����
  sFlag_TruckIn       = 'I';                         //��������
  sFlag_TruckOut      = 'O';                         //��������
  sFlag_TruckBFP      = 'P';                         //����Ƥ�س���
  sFlag_TruckBFM      = 'M';                         //����ë�س���
  sFlag_TruckSH       = 'S';                         //�ͻ�����
  sFlag_TruckFH       = 'F';                         //�Żҳ���
  sFlag_TruckZT       = 'Z';                         //ջ̨����
  sFlag_TruckXH       = 'X';                         //���ճ���

  sFlag_TJNone        = 'N';                         //δ����
  sFlag_TJing         = 'T';                         //������
  sFlag_TJOver        = 'O';                         //�������
  
  sFlag_PoundBZ       = 'B';                         //��׼
  sFlag_PoundPZ       = 'Z';                         //Ƥ��
  sFlag_PoundPD       = 'P';                         //���
  sFlag_PoundCC       = 'C';                         //����(����ģʽ)
  sFlag_PoundLS       = 'L';                         //��ʱ
  
  sFlag_MoneyHuiKuan  = 'R';                         //�ؿ����
  sFlag_MoneyJiaCha   = 'C';                         //���ɼ۲�
  sFlag_MoneyZhiKa    = 'Z';                         //ֽ���ؿ�
  sFlag_MoneyFanHuan  = 'H';                         //�����û�

  sFlag_InvNormal     = 'N';                         //������Ʊ
  sFlag_InvHasUsed    = 'U';                         //���÷�Ʊ
  sFlag_InvInvalid    = 'V';                         //���Ϸ�Ʊ
  sFlag_InvRequst     = 'R';                         //���뿪��
  sFlag_InvDaily      = 'D';                         //�ճ�����

  sFlag_LineGroupAll  = 'A';                         //ͨ������(ȫ������)

  sFlag_LoadExtInfo   = 'ExtInfo;';                  //���븽��
  sFlag_AllowZeroNum  = 'ZeroNum;';                  //����û��

  sFlag_SysParam      = 'SysParam';                  //ϵͳ����
  sFlag_EnableBakdb   = 'Uses_BackDB';               //���ÿ�
  sFlag_ValidDate     = 'SysValidDate';              //��Ч��
  sFlag_ZhiKaVerify   = 'ZhiKaVerify';               //ֽ�����
  sFlag_PrintZK       = 'PrintZK';                   //��ӡֽ��
  sFlag_PrintBill     = 'PrintStockBill';            //���ӡ����
  sFlag_PrintFHD      = 'PrintFHD';                  //��ӡ���˵�
  sFlag_ViaBillCard   = 'ViaBillCard';               //ֱ���ƿ�
  sFlag_PayCredit     = 'Pay_Credit';                //�ؿ������
  sFlag_HYValue       = 'HYMaxValue';                //����������
  sFlag_SaleManDept   = 'SaleManDept';               //�������۵�
  sFlag_HYPackers     = 'HYPackers';                 //������������

  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //��װ�����
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //��װ�����
  sFlag_PDaiPercent   = 'PoundDaiPercent';           //�������������
  sFlag_PDaiWuChaStop = 'PoundDaiWuChaStop';         //���ʱֹͣҵ��
  sFlag_PSanWuChaF    = 'PoundSanWuChaF';            //ɢװ�����
  sFlag_PoundWuCha    = 'PoundWuCha';                //����������
  sFlag_PoundIfDai    = 'PoundIFDai';                //��װ�Ƿ����
  sFlag_NFStock       = 'NoFaHuoStock';              //�ֳ����跢��
  sFlag_StockIfYS     = 'StockIfYS';                 //�ֳ��Ƿ�����
  sFlag_DispatchPound = 'PoundDispatch';             //��վ����
  sFlag_DaiPercentToZero = 'DaiPercentToZero';       //��ͳ��Ϊ�������ı���

  sFlag_CommonItem    = 'CommonItem';                //������Ϣ
  sFlag_CardItem      = 'CardItem';                  //�ſ���Ϣ��
  sFlag_AreaItem      = 'AreaItem';                  //������Ϣ��
  sFlag_TruckItem     = 'TruckItem';                 //������Ϣ��
  sFlag_CustomerItem  = 'CustomerItem';              //�ͻ���Ϣ��
  sFlag_BankItem      = 'BankItem';                  //������Ϣ��
  sFlag_UserLogItem   = 'UserLogItem';               //�û���¼��

  sFlag_StockItem     = 'StockItem';                 //ˮ����Ϣ��
  sFlag_ContractItem  = 'ContractItem';              //��ͬ��Ϣ��
  sFlag_SalesmanItem  = 'SalesmanItem';              //ҵ��Ա��Ϣ��
  sFlag_ZhiKaItem     = 'ZhiKaItem';                 //ֽ����Ϣ��
  sFlag_BillItem      = 'BillItem';                  //�ᵥ��Ϣ��
  sFlag_TruckQueue    = 'TruckQueue';                //��������
  sFlag_ZTLineGroup   = 'ZTLineGroup';               //ջ̨����
                                                               
  sFlag_PaymentItem   = 'PaymentItem';               //���ʽ��Ϣ��
  sFlag_PaymentItem2  = 'PaymentItem2';              //���ۻؿ���Ϣ��
  sFlag_LadingItem    = 'LadingItem';                //�����ʽ��Ϣ��

  sFlag_ProviderItem  = 'ProviderItem';              //��Ӧ����Ϣ��
  sFlag_MaterailsItem = 'MaterailsItem';             //ԭ������Ϣ��

  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_MITSrvURL     = 'MITServiceURL';             //�����ַ
  sFlag_Factoryid     = 'FactoryId';                 //����ID����΢��ƽ̨��������ʱʹ��
  sFlag_AICMWorkshop  = 'aicmworkshop';              //�����쿨ϵͳ-�����������

  sFlag_AutoIn        = 'Truck_AutoIn';              //�Զ�����
  sFlag_AutoOut       = 'Truck_AutoOut';             //�Զ�����
  sFlag_InTimeout     = 'InFactTimeOut';             //������ʱ(����)
  sFlag_InAndBill     = 'InFactAndBill';             //�����������
  sFlag_InAndCreate   = 'InFactAndCreate';           //HY�������
  sFlag_SanMultiBill  = 'SanMultiBill';              //ɢװԤ���൥
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //��װ���ö���
  sFlag_NoSanQueue    = 'NoSanQueue';                //ɢװ���ö���
  sFlag_DelayQueue    = 'DelayQueue';                //�ӳ��Ŷ�(����)
  sFlag_PoundQueue    = 'PoundQueue';                //�ӳ��Ŷ�(�������ݹ�Ƥʱ��)
  sFlag_NetPlayVoice  = 'NetPlayVoice';              //ʹ��������������
  sFlag_SaveHKRecord  = 'SaveHKRecord';              //����ϵ�����Ϣ

  sFlag_BusGroup      = 'BusFunction';               //ҵ�������
  sFlag_BillNo        = 'Bus_Bill';                  //��������
  sFlag_PoundID       = 'Bus_Pound';                 //���ؼ�¼
  sFlag_Customer      = 'Bus_Customer';              //�ͻ����
  sFlag_SaleMan       = 'Bus_SaleMan';               //ҵ��Ա���
  sFlag_ZhiKa         = 'Bus_ZhiKa';                 //ֽ�����
  sFlag_WeiXin        = 'Bus_WeiXin';                //΢��ӳ����
  sFlag_HYDan         = 'Bus_HYDan';                 //���鵥��
  sFlag_ForceHint     = 'Bus_HintMsg';               //ǿ����ʾ
  sFlag_Order         = 'Bus_Order';                 //�ɹ�����
  sFlag_OrderBase     = 'Bus_OrderBase';             //�ɹ����뵥��
  sFlag_OrderDtl      = 'Bus_OrderDtl';              //�ɹ�����
  sFlag_HKRecord      = 'Bus_HKRecord';              //�ϵ����
  sFlag_TransBase     = 'Bus_TransBase';             //�̵����뵥��
  sFlag_Transfer      = 'Bus_Transfer';              //�̵�����

  {*���ݱ�*}
  sTable_Group        = 'Sys_Group';                 //�û���
  sTable_User         = 'Sys_User';                  //�û���
  sTable_Menu         = 'Sys_Menu';                  //�˵���
  sTable_Popedom      = 'Sys_Popedom';               //Ȩ�ޱ�
  sTable_PopItem      = 'Sys_PopItem';               //Ȩ����
  sTable_Entity       = 'Sys_Entity';                //�ֵ�ʵ��
  sTable_DictItem     = 'Sys_DataDict';              //�ֵ���ϸ

  sTable_SysDict      = 'Sys_Dict';                  //ϵͳ�ֵ�
  sTable_ExtInfo      = 'Sys_ExtInfo';               //������Ϣ
  sTable_SysLog       = 'Sys_EventLog';              //ϵͳ��־
  sTable_BaseInfo     = 'Sys_BaseInfo';              //������Ϣ
  sTable_SerialBase   = 'Sys_SerialBase';            //��������
  sTable_SerialStatus = 'Sys_SerialStatus';          //���״̬
  sTable_WorkePC      = 'Sys_WorkePC';               //��֤��Ȩ
  
  sTable_Customer     = 'S_Customer';                //�ͻ���Ϣ
  sTable_Salesman     = 'S_Salesman';                //ҵ����Ա
  sTable_Translator   = 'S_Translator';              //���䵥λ
  sTable_SaleContract = 'S_Contract';                //���ۺ�ͬ
  sTable_SContractExt = 'S_ContractExt';             //��ͬ��չ
  
  sTable_CusAccount   = 'Sys_CustomerAccount';       //�ͻ��˻�
  sTable_InOutMoney   = 'Sys_CustomerInOutMoney';    //�ʽ���ϸ
  sTable_CusCredit    = 'Sys_CustomerCredit';        //�ͻ�����
  sTable_SysShouJu    = 'Sys_ShouJu';                //�վݼ�¼

  sTable_Invoice      = 'Sys_Invoice';               //��Ʊ�б�
  sTable_InvoiceDtl   = 'Sys_InvoiceDetail';         //��Ʊ��ϸ
  sTable_InvoiceWeek  = 'Sys_InvoiceWeek';           //��������
  sTable_InvoiceReq   = 'Sys_InvoiceRequst';         //��������
  sTable_InvReqtemp   = 'Sys_InvoiceReqtemp';        //��ʱ����
  sTable_DataTemp     = 'Sys_DataTemp';              //��ʱ����

  sTable_WeixinLog    = 'Sys_WeixinLog';             //΢����־
  sTable_WeixinMatch  = 'Sys_WeixinMatch';           //�˺�ƥ��
  sTable_WeixinTemp   = 'Sys_WeixinTemplate';        //��Ϣģ��
  sTable_WeixinBind   = 'sys_WeixinCusBind';         //΢���˺Ű�

  sTable_ZhiKa        = 'S_ZhiKa';                   //ֽ������
  sTable_ZhiKaDtl     = 'S_ZhiKaDtl';                //ֽ����ϸ
  sTable_Card         = 'S_Card';                    //���۴ſ�
  sTable_Bill         = 'S_Bill';                    //�����
  sTable_BillBak      = 'S_BillBak';                 //��ɾ������
  sTable_StockMatch   = 'S_StockMatch';              //Ʒ��ӳ��

  sTable_Order        = 'P_Order';                   //�ɹ�����
  sTable_OrderBak     = 'P_OrderBak';                //��ɾ���ɹ�����
  sTable_OrderBase    = 'P_OrderBase';               //�ɹ����붩��
  sTable_OrderBaseBak = 'P_OrderBaseBak';            //��ɾ���ɹ����붩��
  sTable_OrderDtl     = 'P_OrderDtl';                //�ɹ�������ϸ
  sTable_OrderDtlBak  = 'P_OrderDtlBak';             //�ɹ�������ϸ

  sTable_TransBase    = 'P_TransBase';                //�̵���ϸ��
  sTable_TransBaseBak = 'P_TransBaseBak';             //�̵���ϸ��
  sTable_Transfer     = 'P_Transfer';                //�̵���ϸ��
  sTable_TransferBak  = 'P_TransferBak';             //�̵���ϸ��

  sTable_Truck        = 'S_Truck';                   //������
  sTable_ZTLines      = 'S_ZTLines';                 //װ����
  sTable_ZTTrucks     = 'S_ZTTrucks';                //��������

  sTable_Provider     = 'P_Provider';                //�ͻ���
  sTable_Materails    = 'P_Materails';               //���ϱ�
  sTable_PoundLog     = 'Sys_PoundLog';              //��������
  sTable_PoundBak     = 'Sys_PoundBak';              //��������
  sTable_Picture      = 'Sys_Picture';               //���ͼƬ

  sTable_StockParam   = 'S_StockParam';              //Ʒ�ֲ���
  sTable_StockParamExt= 'S_StockParamExt';           //������չ
  sTable_StockRecord  = 'S_StockRecord';             //�����¼
  sTable_StockHuaYan  = 'S_StockHuaYan';             //�����鵥

  sTable_YT_CardInfo  = 'S_YTCardInfo';              //�������ۿ�Ƭ
  sTable_YT_CodeInfo  = 'S_YTCodeInfo';              //����ˮ����
  sTable_YT_Batchcode = 'S_YTBatchcodeInfo';         //����ϵͳ�����¼

  sTable_WebOrderMatch   = 'S_WebOrderMatch';        //�̳Ƕ���ӳ��
  sTable_SpecialCustomerCementcode   = 'S_SpecialCustomerCementcode';        //����ͻ�ˮ����

const
  {*�½���*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(200),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ϵͳ�ֵ�: SysDict
   *.D_ID: ���
   *.D_Name: ����
   *.D_Desc: ����
   *.D_Value: ȡֵ
   *.D_Memo: �����Ϣ
   *.D_ParamA: �������
   *.D_ParamB: �ַ�����
   *.D_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ��չ��Ϣ��: ExtInfo
   *.I_ID: ���
   *.I_Group: ��Ϣ����
   *.I_ItemID: ��Ϣ��ʶ
   *.I_Item: ��Ϣ��
   *.I_Info: ��Ϣ����
   *.I_ParamA: �������
   *.I_ParamB: �ַ�����
   *.I_Memo: ��ע��Ϣ
   *.I_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   ϵͳ��־: SysLog
   *.L_ID: ���
   *.L_Date: ��������
   *.L_Man: ������
   *.L_Group: ��Ϣ����
   *.L_ItemID: ��Ϣ��ʶ
   *.L_KeyID: ������ʶ
   *.L_Event: �¼�
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   ������Ϣ��: BaseInfo
   *.B_ID: ���
   *.B_Group: ����
   *.B_Text: ����
   *.B_Py: ƴ����д
   *.B_Memo: ��ע��Ϣ
   *.B_PID: �ϼ��ڵ�
   *.B_Index: ����˳��
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(R_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer, B_Date DateTime)';
  {-----------------------------------------------------------------------------
   ���б�Ż�����: SerialBase
   *.R_ID: ���
   *.B_Group: ����
   *.B_Object: ����
   *.B_Prefix: ǰ׺
   *.B_IDLen: ��ų�
   *.B_Base: ����
   *.B_Date: �ο�����
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(R_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   ����״̬��: SerialStatus
   *.R_ID: ���
   *.S_Object: ����
   *.S_SerailID: ���б��
   *.S_PairID: ��Ա��
   *.S_Status: ״̬(Y,N)
   *.S_Date: ����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewWorkePC = 'Create Table $Table(R_ID $Inc, W_Name varChar(100),' +
       'W_MAC varChar(32), W_Factory varChar(32), W_Serial varChar(32),' +
       'W_Departmen varChar(32), W_ReqMan varChar(32), W_ReqTime DateTime,' +
       'W_RatifyMan varChar(32), W_RatifyTime DateTime, W_Valid Char(1))';
  {-----------------------------------------------------------------------------
   ������Ȩ: WorkPC
   *.R_ID: ���
   *.W_Name: ��������
   *.W_MAC: MAC��ַ
   *.W_Factory: �������
   *.W_Departmen: ����
   *.W_Serial: ���
   *.W_ReqMan,W_ReqTime: ��������
   *.W_RatifyMan,W_RatifyTime: ��׼
   *.W_Valid: ��Ч(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewSyncItem = 'Create Table $Table(R_ID $Inc, S_Table varChar(100),' +
       'S_Action Char(1), S_Record varChar(32), S_Param1 varChar(100),' +
       'S_Param2 $Float, S_Time DateTime)';
  {-----------------------------------------------------------------------------
   ͬ��������: SyncItem
   *.R_ID: ���
   *.S_Table: ������
   *.S_Action: ��ɾ��(A,E,D)
   *.S_Record: ��¼���
   *.S_Param1,S_Param2: ����
   *.S_Time: ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1))';
  {-----------------------------------------------------------------------------
   ����Ʒ��ӳ��: StockMatch
   *.R_ID: ��¼���
   *.M_Group: ����
   *.M_ID: ���Ϻ�
   *.M_Name: ��������
   *.M_Status: ״̬
  -----------------------------------------------------------------------------}
  
  sSQL_NewSalesMan = 'Create Table $Table(R_ID $Inc, S_ID varChar(15),' +
       'S_Name varChar(30), S_PY varChar(30), S_Phone varChar(20),' +
       'S_Area varChar(50), S_InValid Char(1), S_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ҵ��Ա��: SalesMan
   *.R_ID: ��¼��
   *.S_ID: ���
   *.S_Name: ����
   *.S_PY: ��ƴ
   *.S_Phone: ��ϵ��ʽ
   *.S_Area:��������
   *.S_InValid: ����Ч
   *.S_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewTranslator = 'Create Table $Table(R_ID $Inc, T_ID varChar(32),' +
       'T_Name varChar(80),T_PY varChar(80), T_Phone varChar(20),' +
       'T_Saler varChar(32),T_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ������: Translator
   *.T_ID: ���
   *.T_Name: ����
   *.T_PY: ƴ����д
   *.T_Phone: ��ϵ��ʽ
   *.T_Saler: ҵ��Ա
   *.T_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(R_ID $Inc, C_ID varChar(20), ' +
       'C_Name varChar(80), C_PY varChar(80), C_Addr varChar(100), ' +
       'C_FaRen varChar(50), C_LiXiRen varChar(50), C_WeiXin varChar(15),' +
       'C_Phone varChar(15), C_Fax varChar(15), C_Tax varChar(32),' +
       'C_Bank varChar(35), C_Account varChar(18), C_SaleMan varChar(15),' +
       'C_Param varChar(32), C_Memo varChar(50), C_XuNi Char(1))';
  {-----------------------------------------------------------------------------
   �ͻ���Ϣ��: Customer
   *.R_ID: ��¼��
   *.C_ID: ���
   *.C_Name: ����
   *.C_PY: ƴ����д
   *.C_Addr: ��ַ
   *.C_FaRen: ����
   *.C_LiXiRen: ��ϵ��
   *.C_Phone: �绰
   *.C_WeiXin: ΢��
   *.C_Fax: ����
   *.C_Tax: ˰��
   *.C_Bank: ������
   *.C_Account: �ʺ�
   *.C_SaleMan: ҵ��Ա
   *.C_Param: ���ò���
   *.C_Memo: ��ע��Ϣ
   *.C_XuNi: ����(��ʱ)�ͻ�
  -----------------------------------------------------------------------------}
  
  sSQL_NewCusAccount = 'Create Table $Table(R_ID $Inc, A_CID varChar(20),' +
       'A_Used Char(1), A_InMoney Decimal(15,5) Default 0,' +
       'A_OutMoney Decimal(15,5) Default 0, A_DebtMoney Decimal(15,5) Default 0,' +
       'A_Compensation Decimal(15,5) Default 0,' +
       'A_FreezeMoney Decimal(15,5) Default 0,' +
       'A_CreditLimit Decimal(15,5) Default 0, A_Date DateTime)';
  {-----------------------------------------------------------------------------
   �ͻ��˻�:CustomerAccount
   *.R_ID:��¼���
   *.A_CID:�ͻ���
   *.A_Used:��;(��Ӧ,����)
   *.A_InMoney:���
   *.A_OutMoney:����
   *.A_DebtMoney:Ƿ��
   *.A_Compensation:������
   *.A_FreezeMoney:�����ʽ�
   *.A_CreditLimit:���ö��
   *.A_Date:��������

   *.ˮ����������
     A_InMoney:�ͻ������˻��Ľ��
     A_OutMoney:�ͻ�ʵ�ʻ��ѵĽ��
     A_DebtMoney:��δ֧���Ľ��
     A_Compensation:���ڲ���˻����ͻ��Ľ��
     A_FreezeMoney:�Ѱ�ֽ����δ��������Ľ��
     A_CreditLimit:���Ÿ��û�����߿�Ƿ����

     ������� = ��� + ���ö� - ���� - ������ - �Ѷ���
     �����ܶ� = ���� + Ƿ�� + �Ѷ���
  -----------------------------------------------------------------------------}

  sSQL_NewInOutMoney = 'Create Table $Table(R_ID $Inc, M_SaleMan varChar(15),' +
       'M_CusID varChar(15), M_CusName varChar(80), ' +
       'M_Type Char(1), M_Payment varChar(20),' +
       'M_Money Decimal(15,5), M_ZID varChar(15), M_Date DateTime,' +
       'M_Man varChar(32), M_Memo varChar(200))';
  {-----------------------------------------------------------------------------
   �������ϸ:CustomerInOutMoney
   *.M_ID:��¼���
   *.M_SaleMan:ҵ��Ա
   *.M_CusID:�ͻ���
   *.M_CusName:�ͻ���
   *.M_Type:����(����,�ؿ��)
   *.M_Payment:���ʽ
   *.M_Money:���ɽ��
   *.M_ZID:ֽ����
   *.M_Date:��������
   *.M_Man:������
   *.M_Memo:����

   *.ˮ�����������
     ��� = ���� x ���� + ����
  -----------------------------------------------------------------------------}

  sSQL_NewSysShouJu = 'Create Table $Table(R_ID $Inc ,S_Code varChar(15),' +
       'S_Sender varChar(100), S_Reason varChar(100), S_Money Decimal(15,5),' +
       'S_BigMoney varChar(50), S_Bank varChar(35), S_Man varChar(32),' +
       'S_Date DateTime, S_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   �վ���ϸ:ShouJu
   *.R_ID:���
   *.S_Code:����ƾ������
   *.S_Sender:����(��Դ)
   *.S_Reason:����(����)
   *.S_Money:���
   *.S_Bank:����
   *.S_Man:����Ա
   *.S_Date:����
   *.S_Memo:��ע
  -----------------------------------------------------------------------------}

  sSQL_NewCusCredit = 'Create Table $Table(R_ID $Inc ,C_CusID varChar(15),' +
       'C_Money Decimal(15,5), C_Man varChar(32),' +
       'C_Date DateTime, C_End DateTime, C_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ������ϸ:CustomerCredit
   *.R_ID:���
   *.C_CusID:�ͻ����
   *.C_Money:���Ŷ�
   *.C_Man:������
   *.C_Date:����
   *.C_End: ��Ч��
   *.C_Memo:��ע
  -----------------------------------------------------------------------------}

  sSQL_NewSaleContract = 'Create Table $Table(R_ID $Inc, C_ID varChar(15),' +
       'C_Project varChar(100),C_SaleMan varChar(15), C_Customer varChar(15),' +
       'C_Date varChar(20), C_Area varChar(50), C_Addr varChar(50),' +
       'C_Delivery varChar(50), C_Payment varChar(20), C_Approval varChar(30),' +
       'C_ZKDays Integer, C_XuNi Char(1), C_Freeze Char(1), C_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ���ۺ�ͬ: SalesContract
   *.R_ID: ���
   *.C_Project: ��Ŀ����
   *.C_SaleMan: ������Ա
   *.C_Customer: �ͻ�
   *.C_Date: ǩ��ʱ��
   *.C_Area: ��������
   *.C_Addr: ǩ���ص�
   *.C_Delivery: ������
   *.C_Payment: ���ʽ
   *.C_Approval: ��׼��
   *.C_ZKDays: ֽ����Ч��
   *.C_XuNi: �����ͬ
   *.C_Freeze: �Ƿ񶳽�
   *.C_Memo: ��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewSContractExt = 'Create Table $Table(R_ID $Inc,' +
       'E_CID varChar(15), E_Type Char(1), ' +
       'E_StockNo varChar(20), E_StockName varChar(80),' +
       'E_Value Decimal(15,5), E_Price Decimal(15,5), E_Money Decimal(15,5))';
  {-----------------------------------------------------------------------------
   ���ۺ�ͬ: SalesContract
   *.R_ID: ��¼���
   *.E_CID: ���ۺ�ͬ
   *.E_Type: ����(��,ɢ)
   *.E_StockNo,E_StockName: ˮ������
   *.E_Value: ����
   *.E_Price: ����
   *.E_Money: ���
  -----------------------------------------------------------------------------}

  sSQL_NewZhiKa = 'Create Table $Table(R_ID $Inc,Z_ID varChar(15),' +
       'Z_Name varChar(100),Z_Card varChar(16),' +
       'Z_CID varChar(15), Z_Project varChar(100), Z_Customer varChar(15),' +
       'Z_SaleMan varChar(15), Z_Payment varChar(20), Z_Lading Char(1),' +
       'Z_ValidDays DateTime, Z_Password varChar(16), Z_OnlyPwd Char(1),' +
       'Z_Verified Char(1), Z_InValid Char(1), Z_Freeze Char(1),' +
       'Z_YFMoney $Float, Z_FixedMoney $Float, Z_OnlyMoney Char(1),' +
       'Z_TJStatus Char(1), Z_Memo varChar(200), Z_Man varChar(32),' +
       'Z_Date DateTime)';
  {-----------------------------------------------------------------------------
   ֽ������: ZhiKa
   *.R_ID:��¼���
   *.Z_ID:ֽ����
   *.Z_Card:�ſ���
   *.Z_Name:ֽ������
   *.Z_CID:���ۺ�ͬ
   *.Z_Project:��Ŀ����
   *.Z_Customer:�ͻ����
   *.Z_SaleMan:ҵ��Ա
   *.Z_Payment:���ʽ
   *.Z_Lading:�����ʽ(����,�ͻ�)
   *.Z_ValidDays:��Ч��
   *.Z_Password: ����
   *.Z_OnlyPwd: ͳһ����
   *.Z_Verified:�����
   *.Z_InValid:����Ч
   *.Z_Freeze:�Ѷ���
   *.Z_YFMoney:Ԥ�����
   *.Z_FixedMoney:���ý�
   *.Z_OnlyMoney:ֻʹ�ÿ��ý�
   *.Z_TJStatus:����״̬
   *.Z_Man:������
   *.Z_Date:����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewZhiKaDtl = 'Create Table $Table(R_ID $Inc, D_ZID varChar(15),' +
       'D_Type Char(1), D_StockNo varChar(20), D_StockName varChar(80),' +
       'D_Price $Float, D_Value $Float, D_PPrice $Float, ' +
       'D_TPrice Char(1) Default ''Y'')';
  {-----------------------------------------------------------------------------
   ֽ����ϸ:ZhiKaDtl
   *.R_ID:��¼���
   *.D_ZID:ֽ����
   *.D_Type:����(��,ɢ)
   *.D_StockNo,D_StockName:ˮ������
   *.D_Price:����
   *.D_Value:������
   *.D_PPrice:����ǰ����
   *.D_TPrice:��������
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc,L_ID varChar(20),' +
       'L_HKRecord varChar(20),L_YTID varChar(50),' +
       'L_PrintFH Char(1), L_PrintHGZ Char(1),' +
       'L_Card varChar(16),L_ZhiKa varChar(25),L_Project varChar(100),' +
       'L_Area varChar(50),L_WorkAddr varChar(100),' +
       'L_TransID varChar(32),L_TransName varChar(100),' +
       'L_CusID varChar(25),L_CusName varChar(120),L_CusPY varChar(120),' +
       'L_SaleID varChar(25),L_SaleMan varChar(32),' +
       'L_Type Char(1),L_StockNo varChar(20),L_StockName varChar(80),' +
       'L_Value $Float,L_Price $Float,L_ZKMoney Char(1),' +
       'L_Truck varChar(15),L_Status Char(1),L_NextStatus Char(1),' +
       'L_InTime DateTime,L_InMan varChar(32),' +
       'L_PValue $Float,L_PDate DateTime,L_PMan varChar(32),' +
       'L_MValue $Float,L_MDate DateTime,L_MMan varChar(32),' +
       'L_IsEmpty Char(1),L_LadeTime DateTime,L_LadeMan varChar(32),' +
       'L_LadeLine varChar(15),L_LineName varChar(32),L_LineGroup Char(1),' +
       'L_DaiTotal Integer,L_DaiNormal Integer,L_DaiBuCha Integer,' +
       'L_OutFact DateTime,L_OutMan varChar(32),' +
       'L_Lading Char(1),L_IsVIP Char(1),L_Seal varChar(100),' +
       'L_HYDan varChar(32),L_Man varChar(32),L_Date DateTime,' +
       'L_DelMan varChar(32),L_DelDate DateTime, L_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   ��������: Bill
   *.R_ID: ���
   *.L_ID: �ᵥ��
   *.L_Card: �ſ���
   *.L_ZhiKa: ֽ����
   *.L_Project: �󿨺�
   *.L_Area: ����Ƭ��
   *.L_WorkAddr: ����
   *.L_TransID, L_TransName: ���䵥λ
   *.L_CusID,L_CusName,L_CusPY:�ͻ�
   *.L_SaleID,L_SaleMan:ҵ��Ա
   *.L_Type: ����(��,ɢ)
   *.L_StockNo: ���ϱ��
   *.L_StockName: �������� 
   *.L_Value: �����
   *.L_Price: �������
   *.L_ZKMoney: ռ��ֽ������(Y/N)
   *.L_Truck: ������
   *.L_Status,L_NextStatus:״̬����
   *.L_InTime,L_InMan: ��������
   *.L_PValue,L_PDate,L_PMan: ��Ƥ��
   *.L_MValue,L_MDate,L_MMan: ��ë��
   *.L_LadeTime,L_LadeMan: ����ʱ��,������
   *.L_LadeLine,L_LineName: ����ͨ��
   *.L_DaiTotal,L_DaiNormal,L_DaiBuCha:��װ,����,����
   *.L_OutFact,L_OutMan: ��������
   *.L_Lading: �����ʽ(����,�ͻ�)
   *.L_IsVIP:VIP��
   *.L_Seal: ��ǩ��
   *.L_HYDan: ���鵥
   *.L_Man:������
   *.L_Date:����ʱ��
   *.L_DelMan: ������ɾ����Ա
   *.L_DelDate: ������ɾ��ʱ��
   *.L_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewOrderBase = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Value $Float, B_SentValue $Float,B_RestValue $Float,' +
       'B_LimValue $Float, B_WarnValue $Float,B_FreezeValue $Float,' +
       'B_BStatus Char(1),B_Area varChar(50), B_Project varChar(100),' +
       'B_ProID varChar(32), B_ProName varChar(80), B_ProPY varChar(80),' +
       'B_SaleID varChar(32), B_SaleMan varChar(80), B_SalePY varChar(80),' +
       'B_StockType Char(1), B_StockNo varChar(32), B_StockName varChar(80),' +
       'B_Man varChar(32), B_Date DateTime,' +
       'B_DelMan varChar(32), B_DelDate DateTime, B_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ɹ����뵥��: Order
   *.R_ID: ���
   *.B_ID: �ᵥ��
   *.B_Value,B_SentValue,B_RestValue:���������ѷ�����ʣ����
   *.B_LimValue,B_WarnValue,B_FreezeValue:������������;����Ԥ����,����������
   *.B_BStatus: ����״̬
   *.B_Area,B_Project: ����,��Ŀ
   *.B_ProID,B_ProName,B_ProPY:��Ӧ��
   *.B_SaleID,B_SaleMan,B_SalePY:ҵ��Ա
   *.B_StockType: ����(��,ɢ)
   *.B_StockNo: ԭ���ϱ��
   *.B_StockName: ԭ��������
   *.B_Man:������
   *.B_Date:����ʱ��
   *.B_DelMan: �ɹ����뵥ɾ����Ա
   *.B_DelDate: �ɹ����뵥ɾ��ʱ��
   *.B_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewOrder = 'Create Table $Table(R_ID $Inc, O_ID varChar(20),' +
       'O_BID varChar(20),O_Card varChar(16), O_CType varChar(1),' +
       'O_Value $Float,O_Area varChar(50), O_Project varChar(100),' +
       'O_ProID varChar(32), O_ProName varChar(80), O_ProPY varChar(80),' +
       'O_SaleID varChar(32), O_SaleMan varChar(80), O_SalePY varChar(80),' +
       'O_Type Char(1), O_StockNo varChar(32), O_StockName varChar(80),' +
       'O_Truck varChar(15), O_OStatus Char(1),' +
       'O_Man varChar(32), O_Date DateTime,' +
       'O_DelMan varChar(32), O_DelDate DateTime, O_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ɹ�������: Order
   *.R_ID: ���
   *.O_ID: �ᵥ��
   *.O_BID: �ɹ����뵥�ݺ�
   *.O_Card,O_CType: �ſ���,�ſ�����(L����ʱ��;G���̶���)
   *.O_Value:��������
   *.O_OStatus: ����״̬
   *.O_Area,O_Project: ����,��Ŀ
   *.O_ProID,O_ProName,O_ProPY:��Ӧ��
   *.O_SaleID,O_SaleMan:ҵ��Ա
   *.O_Type: ����(��,ɢ)
   *.O_StockNo: ԭ���ϱ��
   *.O_StockName: ԭ��������
   *.O_Truck: ������
   *.O_Man:������
   *.O_Date:����ʱ��
   *.O_DelMan: �ɹ���ɾ����Ա
   *.O_DelDate: �ɹ���ɾ��ʱ��
   *.O_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewOrderDtl = 'Create Table $Table(R_ID $Inc, D_ID varChar(20),' +
       'D_OID varChar(20), D_PID varChar(20), D_Card varChar(16), ' +
       'D_DStatus Char(1), D_Status Char(1), D_NextStatus Char(1),' +
       'D_InTime DateTime, D_InMan varChar(32),' +
       'D_PValue $Float, D_PDate DateTime, D_PMan varChar(32),' +
       'D_MValue $Float, D_MDate DateTime, D_MMan varChar(32),' +
       'D_YTime DateTime, D_YMan varChar(32), ' +
       'D_Value $Float,D_KZValue $Float, D_AKValue $Float,' +
       'D_YLine varChar(15), D_YLineName varChar(32), ' +
       'D_DelMan varChar(32), D_DelDate DateTime, D_YSResult Char(1), ' +
       'D_OutFact DateTime, D_OutMan varChar(32), D_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ɹ�������ϸ��: OrderDetail
   *.R_ID: ���
   *.D_ID: �ɹ���ϸ��
   *.D_OID: �ɹ�����
   *.D_PID: ������
   *.D_Card: �ɹ��ſ���
   *.D_DStatus: ����״̬
   *.D_Status,D_NextStatus: ״̬
   *.D_InTime,D_InMan: ��������
   *.D_PValue,D_PDate,D_PMan: ��Ƥ��
   *.D_MValue,D_MDate,D_MMan: ��ë��
   *.D_YTime,D_YMan: �ջ�ʱ��,������,
   *.D_Value,D_KZValue,D_AKValue: �ջ���,���տ۳�(����),����
   *.D_YLine,D_YLineName: �ջ�ͨ��
   *.D_YSResult: ���ս��
   *.D_OutFact,D_OutMan: ��������
  -----------------------------------------------------------------------------}

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(32),' +
       'C_Card2 varChar(32), C_Card3 varChar(32),' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ſ���:Card
   *.R_ID:��¼���
   *.C_Card:������
   *.C_Card2,C_Card3:������
   *.C_Owner:�����˱�ʶ
   *.C_TruckNo:�������
   *.C_Used:��;(��Ӧ,����,��ʱ)
   *.C_UseTime:ʹ�ô���
   *.C_Status:״̬(����,ʹ��,ע��,��ʧ)
   *.C_Freeze:�Ƿ񶳽�
   *.C_Man:������
   *.C_Date:����ʱ��
   *.C_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}

    sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), T_Used Char(1), ' +
       'T_OwnerIDCard varChar(64), T_SerialNO varChar(64),' +
       'T_PrePValue $Float, T_PrePMan varChar(32), T_PrePTime DateTime, ' +
       'T_PrePUse Char(1), T_MinPVal $Float, T_MaxPVal $Float, ' +
       'T_PValue $Float Default 0, T_PTime Integer Default 0,' +
       'T_PlateColor varChar(12),T_Type varChar(12), T_LastTime DateTime, ' +
       'T_Card varChar(32), T_CardUse Char(1), T_NoVerify Char(1),' +
       'T_IDCard varChar(32), T_Valid Char(1), T_VIPTruck Char(1), T_HasGPS Char(1))';
  {-----------------------------------------------------------------------------
   ������Ϣ:Truck
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_PY: ����ƴ��
   *.T_Owner: ����
   *.T_Phone: ��ϵ��ʽ
   *.T_OwnerIDCard: ��������֤��
   *.T_SerialNO: �г�֤��
   *.T_Used: ��;(��Ӧ,����)
   *.T_PrePValue: Ԥ��Ƥ��
   *.T_PrePMan: Ԥ��˾��
   *.T_PrePTime: Ԥ��ʱ��
   *.T_PrePUse: ʹ��Ԥ��
   *.T_MinPVal: ��ʷ��СƤ��
   *.T_MaxPVal: ��ʷ���Ƥ��
   *.T_PValue: ��ЧƤ��
   *.T_PTime: ��Ƥ����
   *.T_PlateColor: ������ɫ
   *.T_Type: ����
   *.T_LastTime: �ϴλ
   *.T_Card: ���ӱ�ǩ
   *.T_CardUse: ʹ�õ���ǩ(Y/N)
   *.T_NoVerify: ��У��ʱ��
   *.T_Valid: �Ƿ���Ч
   *.T_IDCard: ID��
   *.T_VIPTruck:�Ƿ�VIP
   *.T_HasGPS:��װGPS(Y/N)

   ��Чƽ��Ƥ���㷨:
   T_PValue = (T_PValue * T_PTime + ��Ƥ��) / (T_PTime + 1)
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(32),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_FactID varChar(32), P_PStation varChar(10), P_MStation varChar(10),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1,' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_KZValue $Float)';
  {-----------------------------------------------------------------------------
   ������¼: Materails
   *.P_ID: ���
   *.P_Type: ����(����,��Ӧ,��ʱ)
   *.P_Order: ������(��Ӧ)
   *.P_Bill: ������
   *.P_Truck: ����
   *.P_CusID: �ͻ���
   *.P_CusName: ������
   *.P_MID: ���Ϻ�
   *.P_MName: ������
   *.P_MType: ��,ɢ��
   *.P_LimValue: Ʊ��
   *.P_PValue,P_PDate,P_PMan: Ƥ��
   *.P_MValue,P_MDate,P_MMan: ë��
   *.P_FactID: �������
   *.P_PStation,P_MStation: ���ذ�վ
   *.P_Direction: ��������(��,��)
   *.P_PModel: ����ģʽ(��׼,��Ե�)
   *.P_Status: ��¼״̬
   *.P_Valid: �Ƿ���Ч
   *.P_PrintNum: ��ӡ����
   *.P_DelMan,P_DelDate: ɾ����¼
   *.P_KZValue: ��Ӧ����
  -----------------------------------------------------------------------------}

  sSQL_NewTransBase = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Card varChar(32), B_Truck varChar(15), B_TID varChar(15),' +
       'B_SrcAddr varChar(160), B_DestAddr varChar(160),' +
       'B_Type Char(1), B_StockNo varChar(32), B_StockName varChar(160),' +
       'B_PValue $Float, B_PDate DateTime, B_PMan varChar(32),' +
       'B_MValue $Float, B_MDate DateTime, B_MMan varChar(32),' +
       'B_Status Char(1), B_NextStatus Char(1), B_IsUsed Char(1),' +
       'B_Value $Float, B_Man varChar(32), B_Date DateTime,' +
       'B_DelMan varChar(32), B_DelDate DateTime, B_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �̵�������: TransBase
   *.R_ID: ���
   *.B_ID: �̵��������
   *.B_Card: �ſ���
   *.B_Truck: ���ƺ�
   *.B_SrcAddr:�����ص�
   *.B_DestAddr:����ص�
   *.B_Type: ����(��,ɢ)
   *.B_StockNo: ���ϱ��
   *.B_StockName: ��������
   *.B_PValue,B_PDate,B_PMan: ��Ƥ��
   *.B_MValue,B_MDate,B_MMan: ��ë��
   *.B_Status: ��ǰ����״̬
   *.B_NextStus: ��һ״̬
   *.B_IsUsed: �����Ƿ�ռ��(Y������ʹ��;N��δռ��)
   *.B_Value: �ջ���
   *.B_Man,B_Date: ������Ϣ
   *.B_DelMan,B_DelDate: ɾ����Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewTransfer = 'Create Table $Table(R_ID $Inc, T_ID varChar(20),' +
       'T_Card varChar(32), T_Truck varChar(15), T_PID varChar(15),' +
       'T_SrcAddr varChar(160), T_DestAddr varChar(160),' +
       'T_Type Char(1), T_StockNo varChar(32), T_StockName varChar(160),' +
       'T_PValue $Float, T_PDate DateTime, T_PMan varChar(32),' +
       'T_MValue $Float, T_MDate DateTime, T_MMan varChar(32),' +
       'T_Status Char(1), T_NextStatus Char(1), ' +
       'T_Value $Float, T_Man varChar(32), T_Date DateTime,' +
       'T_InTime DateTime, T_InMan varChar(32),' +
       'T_OutFact DateTime, T_OutMan varChar(32),' +
       'T_DelMan varChar(32), T_DelDate DateTime, T_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �볧��: Transfer
   *.R_ID: ���
   *.T_ID: �̵�ҵ���
   *.T_PID: �������
   *.T_Card: �ſ���
   *.T_Truck: ���ƺ�
   *.T_SrcAddr:�����ص�
   *.T_DestAddr:����ص�
   *.T_Type: ����(��,ɢ)
   *.T_StockNo: ���ϱ��
   *.T_StockName: ��������
   *.T_PValue,T_PDate,T_PMan: ��Ƥ��
   *.T_MValue,T_MDate,T_MMan: ��ë��
   *.T_Value: �ջ���
   *.T_Man,T_Date: ������Ϣ
   *.T_InMan,T_InTime:������Ϣ
   *.T_OutMan,T_OutFact:������Ϣ
   *.T_DelMan,T_DelDate: ɾ����Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewPicture = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Name varChar(32), P_Mate varChar(80), P_Date DateTime, P_Picture Image)';
  {-----------------------------------------------------------------------------
   ͼƬ: Picture
   *.P_ID: ���
   *.P_Name: ����
   *.P_Mate: ����
   *.P_Date: ʱ��
   *.P_Picture: ͼƬ
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_Group Char(1), Z_StockNo varChar(20),' +
       'Z_Stock varChar(80), Z_StockType Char(1), Z_PeerWeight Integer,' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer)';
  {-----------------------------------------------------------------------------
   װ��������: ZTLines
   *.R_ID: ��¼��
   *.Z_ID: ���
   *.Z_Name: ����
   *.Z_Group: ����
   *.Z_StockNo: Ʒ�ֱ��
   *.Z_Stock: Ʒ��
   *.Z_StockType: ����(��,ɢ)
   *.Z_PeerWeight: ����
   *.Z_QueueMax: ���д�С
   *.Z_VIPLine: VIPͨ��
   *.Z_Valid: �Ƿ���Ч
   *.Z_Index: ˳������
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_LineGroup Char(1), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0,' +
       'T_PDate DateTime, T_IsPound Char(1),T_HKBills varChar(200),' +
       'T_HKRecord varChar(20))';
  {-----------------------------------------------------------------------------
   ��װ������: ZTTrucks
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_StockNo: Ʒ�ֱ��
   *.T_Stock: Ʒ������
   *.T_Type: Ʒ������(D,S)
   *.T_Line: ���ڵ�
   *.T_LineGroup: ͨ������
   *.T_Index: ˳������
   *.T_InTime: ���ʱ��
   *.T_InFact: ����ʱ��
   *.T_InQueue: ����ʱ��
   *.T_InLade: ���ʱ��
   *.T_VIP: ��Ȩ
   *.T_Bill: �ᵥ��
   *.T_Valid: �Ƿ���Ч
   *.T_Value: �����
   *.T_PeerWeight: ����
   *.T_Total: ��װ����
   *.T_Normal: ��������
   *.T_BuCha: �������
   *.T_PDate: ����ʱ��
   *.T_IsPound: �����(Y/N)
   *.T_HKBills: �Ͽ��������б�
  -----------------------------------------------------------------------------}

  sSQL_NewDataTemp = 'Create Table $Table(T_SysID varChar(15))';
  {-----------------------------------------------------------------------------
   ��ʱ���ݱ�: DataTemp
   *.T_SysID: ϵͳ���
  -----------------------------------------------------------------------------}
  
  sSQL_NewInvoiceWeek = 'Create Table $Table(W_ID $Inc, W_NO varChar(15),' +
       'W_Name varChar(50), W_Begin DateTime, W_End DateTime,' +
       'W_Man varChar(32), W_Date DateTime, W_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ��Ʊ��������:InvoiceWeek
   *.W_ID:��¼���
   *.W_NO:���ڱ��
   *.W_Name:����
   *.W_Begin:��ʼ
   *.W_End:����
   *.W_Man:������
   *.W_Date:����ʱ��
   *.W_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}
  
  sSQL_NewInvoice = 'Create Table $Table(I_ID varChar(25) PRIMARY KEY,' +
       'I_Week varChar(15), I_CusID varChar(15), I_Customer varChar(80),' +
       'I_SaleID varChar(15), I_SaleMan varChar(50), I_Status Char(1),' +
       'I_Flag Char(1), I_InMan varChar(32), I_InDate DateTime,' +
       'I_OutMan varChar(32), I_OutDate DateTime, I_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ��ƱƱ��:Invoice
   *.I_ID:���
   *.I_Week:��������
   *.I_CusID:�ͻ����
   *.I_Customer:�ͻ���
   *.I_SaleID:ҵ��Ա��
   *.I_SaleMan:ҵ��Ա
   *.I_Status:״̬
   *.I_Flag:���
   *.I_InMan:¼����
   *.I_InDate:¼������
   *.I_OutMan:������
   *.I_OutDate:��������
   *.I_Memo:��ע
  -----------------------------------------------------------------------------}

  sSQL_NewInvoiceDtl = 'Create Table $Table(D_ID $Inc, D_Invoice varChar(25),' +
       'D_Type Char(1), D_Stock varChar(30), D_Price $Float Default 0,' +
       'D_Value $Float Default 0, D_KPrice $Float Default 0,' +
       'D_DisCount $Float Default 0, D_DisMoney $Float Default 0)';
  {-----------------------------------------------------------------------------
   ��Ʊ��ϸ:InvoiceDetail
   *.D_ID:���
   *.D_Invoice:Ʊ��
   *.D_Type:����(��,ɢ)
   *.D_Stock:Ʒ��
   *.D_Price:����
   *.D_Value:��Ʊ��
   *.D_KPrice:��Ʊ��
   *.D_DisCount:�ۿ۱�
   *.D_DisMoney:�ۿ�Ǯ��
  -----------------------------------------------------------------------------}

  sSQL_NewInvoiceReq = 'Create Table $Table(R_ID $Inc, R_Week varChar(15),' +
       'R_CusID varChar(15), R_Customer varChar(80),' +
       'R_SaleID varChar(15), R_SaleMan varChar(50), R_Type Char(1),' +
       'R_Stock varChar(30), R_Price $Float, R_Value $Float, ' +
       'R_PreHasK $Float Default 0, R_ReqValue $Float, R_KPrice $Float,' +
       'R_KValue $Float Default 0, R_KOther $Float Default 0,' +
       'R_Man varChar(32), R_Date DateTime)';
  {-----------------------------------------------------------------------------
   ��Ʊ��������:InvoiceReq
   *.R_ID:��¼���
   *.R_Week:��������
   *.R_CusID:�ͻ���
   *.R_Customer:�ͻ���
   *.R_SaleID:ҵ��Ա��
   *.R_SaleMan:ҵ��Ա��
   *.R_Type:ˮ������(D,S)
   *.R_Stock:ˮ������
   *.R_Price:����
   *.R_Value:�����
   *.R_PreHasK:֮ǰ�ѿ���
   *.R_ReqValue:������
   *.R_KPrice:��Ʊ����
   *.R_KValue:�����������
   *.R_KOther:����������֮���ѿ�
   *.R_Man:������
   *.R_Date:����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewWXLog = 'Create Table $Table(R_ID $Inc, L_UserID varChar(50), ' +
       'L_Data varChar(2000), L_MsgID varChar(20), L_Result varChar(150),' +
       'L_Count Integer Default 0, L_Status Char(1), ' +
       'L_Comment varChar(100), L_Date DateTime)';
  {-----------------------------------------------------------------------------
   ΢�ŷ�����־:WeixinLog
   *.R_ID:��¼���
   *.L_UserID: ������ID
   *.L_Data:΢������
   *.L_Count:���ʹ���
   *.L_MsgID: ΢�ŷ��ر�ʶ
   *.L_Result:���ͷ�����Ϣ
   *.L_Status:����״̬(N������,I������,Y�ѷ���)
   *.L_Comment:��ע
   *.L_Date: ����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewWXMatch = 'Create Table $Table(R_ID $Inc, M_ID varChar(15), ' +
       'M_WXID varChar(50), M_WXName varChar(64), M_WXFactory varChar(15), ' +
       'M_IsValid Char(1), M_Comment varChar(100), ' +
       'M_AttentionID varChar(32), M_AttentionType Char(1))';
  {-----------------------------------------------------------------------------
   ΢���˻�:WeixinMatch
   *.R_ID:��¼���
   *.M_ID: ΢�ű��
   *.M_WXID:����ID
   *.M_WXName:΢����
   *.M_WXFactory:΢��ע�Ṥ������
   *.M_IsValid: �Ƿ���Ч
   *.M_Comment: ��ע             
   *.M_AttentionID,M_AttentionType: ΢�Ź�ע�ͻ�ID,����(S��ҵ��Ա;C���ͻ�;G������Ա)
  -----------------------------------------------------------------------------}

  sSQL_NewWXTemplate = 'Create Table $Table(R_ID $Inc, W_Type varChar(15), ' +
       'W_TID varChar(50), W_TFields varChar(64), ' +
       'W_TComment Char(300), W_IsValid Char(1))';
  {-----------------------------------------------------------------------------
   ΢���˻�:WeixinMatch
   *.R_ID:��¼���
   *.W_Type:����
   *.W_TID:��ʶ
   *.W_TFields:�������
   *.W_IsValid: �Ƿ���Ч
   *.W_TComment: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewWeixinCusBind = 'Create Table $Table(R_ID $Inc, wcb_Phone varchar(11),'
        +'wcb_Appid varchar(20),wcb_Bindcustomerid varchar(32),wcb_Namepinyin varchar(20),'
        +'wcb_Email varchar(20),wcb_Openid varchar(28),wcb_Binddate varchar(25),'
        +'wcb_WebMallStatus char(1))';
  {-----------------------------------------------------------------------------
  sys_WeixinCusBind΢�ſͻ���
  *.R_ID:��¼��
  *.wcb_Phone:�绰����
  *.wcb_Appid:appid
  *.wcb_Bindcustomerid:�󶨿ͻ�id
  *.wcb_Namepinyin:����
  *.wcb_Email:����
  *.wcb_Openid:openid
  *.wcb_Binddate:������
  *.wcb_WebMallStatus:�Ƿ�ͨ�̳��û���Ĭ��ֵ0��δ��ͨ 1���ѿ�ͨ
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(80),P_PY varChar(80), P_Phone varChar(20),' +
       'P_Saler varChar(32),P_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ��Ӧ��: Provider
   *.P_ID: ���
   *.P_Name: ����
   *.P_PY: ƴ����д
   *.P_Phone: ��ϵ��ʽ
   *.P_Saler: ҵ��Ա
   *.P_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(R_ID $Inc, M_ID varChar(32),' +
       'M_Name varChar(80),M_PY varChar(80),M_Unit varChar(20),M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50), ' +
       'M_IFSale Char(1))';
  {-----------------------------------------------------------------------------
   ���ϱ�: Materails
   *.M_ID: ���
   *.M_Name: ����
   *.M_PY: ƴ����д
   *.M_Unit: ��λ
   *.M_PrePValue: Ԥ��Ƥ��
   *.M_PrePTime: Ƥ��ʱ��(��)
   *.M_IFSale: �Ƿ���Ϊ����Ʒ��(Y,��;��������)
   *.M_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewStockParam = 'Create Table $Table(P_ID varChar(15), P_Stock varChar(30),' +
       'P_Type Char(1), P_Name varChar(50), P_QLevel varChar(20), P_Memo varChar(50),' +
       'P_MgO varChar(20), P_SO3 varChar(20), P_ShaoShi varChar(20),' +
       'P_CL varChar(20), P_BiBiao varChar(20), P_ChuNing varChar(20),' +
       'P_ZhongNing varChar(20), P_AnDing varChar(20), P_XiDu varChar(20),' +
       'P_Jian varChar(20), P_ChouDu varChar(20), P_BuRong varChar(20),' +
       'P_YLiGai varChar(20), P_Water varChar(20), P_KuangWu varChar(20),' +
       'P_GaiGui varChar(20), P_3DZhe varChar(20), P_28Zhe varChar(20),' +
       'P_3DYa varChar(20), P_28Ya varChar(20))';
  {-----------------------------------------------------------------------------
   Ʒ�ֲ���:StockParam
   *.P_ID:��¼���
   *.P_Stock:Ʒ��
   *.P_Type:����(��,ɢ)
   *.P_Name:�ȼ���
   *.P_QLevel:ǿ�ȵȼ�
   *.P_Memo:��ע
   *.P_MgO:����þ
   *.P_SO3:��������
   *.P_ShaoShi:��ʧ��
   *.P_CL:������
   *.P_BiBiao:�ȱ����
   *.P_ChuNing:����ʱ��
   *.P_ZhongNing:����ʱ��
   *.P_AnDing:������
   *.P_XiDu:ϸ��
   *.P_Jian:���
   *.P_ChouDu:����
   *.P_BuRong:������
   *.P_YLiGai:�����
   *.P_Water:��ˮ��
   *.P_KuangWu:�����ο���
   *.P_GaiGui:�ƹ��
   *.P_3DZhe:3�쿹��ǿ��
   *.P_28DZhe:28����ǿ��
   *.P_3DYa:3�쿹ѹǿ��
   *.P_28DYa:28��ѹǿ��
  -----------------------------------------------------------------------------}

  sSQL_NewStockRecord = 'Create Table $Table(R_ID $Inc, R_SerialNo varChar(15),' +
       'R_PID varChar(15),' +
       'R_SGType varChar(20), R_SGValue varChar(20),' +
       'R_HHCType varChar(20), R_HHCValue varChar(20),' +
       'R_MgO varChar(20), R_SO3 varChar(20), R_ShaoShi varChar(20),' +
       'R_CL varChar(20), R_BiBiao varChar(20), R_ChuNing varChar(20),' +
       'R_ZhongNing varChar(20), R_AnDing varChar(20), R_XiDu varChar(20),' +
       'R_Jian varChar(20), R_ChouDu varChar(20), R_BuRong varChar(20),' +
       'R_YLiGai varChar(20), R_Water varChar(20), R_KuangWu varChar(20),' +
       'R_GaiGui varChar(20),' +
       'R_3DZhe1 varChar(20), R_3DZhe2 varChar(20), R_3DZhe3 varChar(20),' +
       'R_28Zhe1 varChar(20), R_28Zhe2 varChar(20), R_28Zhe3 varChar(20),' +
       'R_3DYa1 varChar(20), R_3DYa2 varChar(20), R_3DYa3 varChar(20),' +
       'R_3DYa4 varChar(20), R_3DYa5 varChar(20), R_3DYa6 varChar(20),' +
       'R_28Ya1 varChar(20), R_28Ya2 varChar(20), R_28Ya3 varChar(20),' +
       'R_28Ya4 varChar(20), R_28Ya5 varChar(20), R_28Ya6 varChar(20),' +
       'R_Date DateTime, R_Man varChar(32))';
  {-----------------------------------------------------------------------------
   �����¼:StockRecord
   *.R_ID:��¼���
   *.R_SerialNo:ˮ����
   *.R_PID:Ʒ�ֲ���
   *.R_SGType: ʯ������
   *.R_SGValue: ʯ�������
   *.R_HHCType: ��ϲ�����
   *.R_HHCValue: ��ϲĲ�����
   *.R_MgO:����þ
   *.R_SO3:��������
   *.R_ShaoShi:��ʧ��
   *.R_CL:������
   *.R_BiBiao:�ȱ����
   *.R_ChuNing:����ʱ��
   *.R_ZhongNing:����ʱ��
   *.R_AnDing:������
   *.R_XiDu:ϸ��
   *.R_Jian:���
   *.R_ChouDu:����
   *.R_BuRong:������
   *.R_YLiGai:�����
   *.R_Water:��ˮ��
   *.R_KuangWu:�����ο���
   *.R_GaiGui:�ƹ��
   *.R_3DZhe1:3�쿹��ǿ��1
   *.R_3DZhe2:3�쿹��ǿ��2
   *.R_3DZhe3:3�쿹��ǿ��3
   *.R_28Zhe1:28����ǿ��1
   *.R_28Zhe2:28����ǿ��2
   *.R_28Zhe3:28����ǿ��3
   *.R_3DYa1:3�쿹ѹǿ��1
   *.R_3DYa2:3�쿹ѹǿ��2
   *.R_3DYa3:3�쿹ѹǿ��3
   *.R_3DYa4:3�쿹ѹǿ��4
   *.R_3DYa5:3�쿹ѹǿ��5
   *.R_3DYa6:3�쿹ѹǿ��6
   *.R_28Ya1:28��ѹǿ��1
   *.R_28Ya2:28��ѹǿ��2
   *.R_28Ya3:28��ѹǿ��3
   *.R_28Ya4:28��ѹǿ��4
   *.R_28Ya5:28��ѹǿ��5
   *.R_28Ya6:28��ѹǿ��6
   *.R_Date:ȡ������
   *.R_Man:¼����
  -----------------------------------------------------------------------------}

  sSQL_NewStockHuaYan = 'Create Table $Table(H_ID $Inc, H_No varChar(15),' +
       'H_Custom varChar(15), H_CusName varChar(80), H_SerialNo varChar(15),' +
       'H_Truck varChar(15), H_Value $Float, H_BillDate DateTime,' +
       'H_EachTruck Char(1), H_ReportDate DateTime, H_Reporter varChar(32))';
  {-----------------------------------------------------------------------------
   �����鵥:StockHuaYan
   *.H_ID:��¼���
   *.H_No:���鵥��
   *.H_Custom:�ͻ����
   *.H_CusName:�ͻ�����
   *.H_SerialNo:ˮ����
   *.H_Truck:�������
   *.H_Value:�����
   *.H_BillDate:�������
   *.H_EachTruck: �泵����
   *.H_ReportDate:��������
   *.H_Reporter:������
  -----------------------------------------------------------------------------}

  sSQL_NewYTCard = 'Create Table $Table(R_ID $Inc, C_ID varChar(20),' +
       'C_Card varChar(50), C_Stock varChar(32), C_Freeze $Float, C_HasDone $Float)';
  {-----------------------------------------------------------------------------
   ������: Order
   *.R_ID: ��¼���
   *.C_ID: ��¼���
   *.C_Card: ��Ƭ���
   *.C_Stock: Ʒ�ֱ��
   *.C_Freeze: ������
   *.C_HasDone: �����
  -----------------------------------------------------------------------------}

  sSQL_NewYTCode = 'Create Table $Table(R_ID $Inc, C_ID varChar(20),' +
       'C_Code varChar(50), C_Stock varChar(32), C_Freeze $Float, C_HasDone $Float)';
  {-----------------------------------------------------------------------------
   ˮ���ű�: YTCode
   *.R_ID: ��¼���
   *.C_ID: �����¼
   *.C_Code: ˮ����
   *.C_Stock: Ʒ�ֱ��
   *.C_Freeze: ������
   *.C_HasDone: �����
  -----------------------------------------------------------------------------}

  sSQL_NewYTBatchcode = 'Create Table $Table(R_ID $Inc, CNO_ID varChar(64),' +
       'CNO_NotifyID varChar (32), CNO_CementCode varChar (32), ' +
       'CNO_CementYear varChar (32), CNO_PackCode varChar (32), ' +
       'CNO_Cement varChar (32), CNO_Depositary varChar (32), ' +
       'CNO_Count varChar (32), CNO_RemainCount varChar (32), ' +
       'CNO_PackDate varChar (32), CNO_SetDate varChar (32), ' +
       'CNO_OperMan varChar (32), CNO_ClientID varChar (32), ' +
       'CNO_Status varChar (32), CNO_Del varChar (32), ' +
       'CNO_Creator varChar (32), CNO_CDate varChar (32), ' +
       'CNO_Mender varChar (32), CNO_MDate varChar (32), ' +
       'CNO_Firm varChar (32), CNO_Remark varChar (500), ' +
       'PAW_ID varChar (32), PAW_Analy varChar (32), ' +
       'PAW_Cement varChar (32), PAW_Intensity varChar (32), ' +
       'PAW_Store varChar (32), PAW_OutDate varChar (32), ' +
       'PAW_Outnumber varChar (32), PAW_Stability varChar (32), ' +
       'PAW_ProduDate varChar (32), PAW_MoldDate varChar (32), ' +
       'PAW_Cohereend varChar (32), PAW_Facttab varChar (32), ' +
       'PAW_Thick varChar (32), PAW_Fine varChar (32), ' +
       'PAW_Waterash varChar (32), PAW_SurfaceArea varChar (32), ' +
       'PAW_Mixture varChar (32), PAW_MoldMan varChar (32), ' +
       'PAW_WhipMan varChar (32), PAW_CohereMan varChar (32), ' +
       'PAW_BreakMan varChar (32), PAW_Remark varChar (500), ' +
       'PAW_3Dcensor varChar (32), PAW_3Dconceit varChar (32), ' +
       'PAW_3DcenMan varChar (32), PAW_3DcenDate varChar (32), ' +
       'PAW_28Dcensor varChar (32), PAW_28Dconceit varChar (32), ' +
       'PAW_28DcenMan varChar (32), PAW_28DcenDate varChar (32), ' +
       'PAW_IsAudit varChar (32), PAW_AuditMan varChar (32), ' +
       'PAW_AuditDate varChar (32), PAW_Del varChar (32), ' +
       'PAW_Creator varChar (32), PAW_CDate varChar (32), ' +
       'PAW_Mender varChar (32), PAW_MDate varChar (32), ' +
       'PAW_Temp1 varChar (32), PAW_Temp2 varChar (32), '  +
       'PAW_Temp3 varChar (32), PAW_Temp4 varChar (32), '  +
       'PAW_Temp5 varChar (32), PAW_Temp6 varChar (32), '  +
       'PAW_Temp7 varChar (32), PAW_Temp8 varChar (32), '  +
       'PAW_Temp9 varChar (32), PAW_Temp10 varChar (32), '  +
       'PAW_Temp11 varChar (32), PAW_Temp12 varChar (32), '  +
       'PAW_Temp13 varChar (32), PAW_Temp14 varChar (32), '  +
       'PAW_Temp15 varChar (32), PAW_Temp16 varChar (32), '  +
       'PAW_Temp17 varChar (32), PAW_Temp18 varChar (32), '  +
       'PAW_Temp19 varChar (32), PAW_Temp20 varChar (32), '  +
       'PAW_Temp21 varChar (32), PAW_Temp22 varChar (32), '  +
       'PAW_Temp23 varChar (32), PAW_Temp24 varChar (32), '  +
       'PAW_Temp25 varChar (32), PAW_Temp26 varChar (32), '  +
       'PAW_Temp27 varChar (32), PAW_Temp28 varChar (32), '  +
       'PAW_Temp29 varChar (32), PAW_Temp30 varChar (32), '  +
       'PAW_Temp31 varChar (32), PAW_Temp32 varChar (32), '  +
       'PAW_Temp33 varChar (32), PAW_Temp34 varChar (32), '  +
       'PAW_Temp35 varChar (32), PAW_Temp36 varChar (32), '  +
       'PAW_Temp37 varChar (32), PAW_Temp38 varChar (32), '  +
       'PAW_Temp39 varChar (32), PAW_Temp40 varChar (32), '  +
       'PAW_Temp41 varChar (32), PAW_Temp42 varChar (32), '  +
       'PAW_Temp43 varChar (32), PAW_Temp44 varChar (32), '  +
       'PAW_Temp45 varChar (32), PAW_Temp46 varChar (32), '  +
       'PAW_Temp47 varChar (32), PAW_Temp48 varChar (32), '  +
       'PAW_Temp49 varChar (32), PAW_Temp50 varChar (32), '  +
       'PAW_Temp51 varChar (32), PAW_Temp52 varChar (32), '  +
       'PAW_Temp53 varChar (32), PAW_Temp54 varChar (32), '  +
       'PAW_Temp55 varChar (32), PAW_Temp56 varChar (32), '  +
       'PAW_Temp57 varChar (32), PAW_Temp58 varChar (32), '  +
       'PAW_Temp59 varChar (32), PAW_Temp60 varChar (32), '  +
       'PAW_Temp61 varChar (32), PAW_Temp62 varChar (32), '  +
       'PAW_Temp63 varChar (32), PAW_Temp64 varChar (32), '  +
       'PAW_Temp65 varChar (32), PAW_Temp66 varChar (32), '  +
       'PAW_Temp67 varChar (32), PAW_Temp68 varChar (32), '  +
       'PAW_Temp69 varChar (32), PAW_Temp70 varChar (32), '  +
       'PAW_Temp71 varChar (32), PAW_Temp72 varChar (32), '  +
       'PAW_Temp73 varChar (32), PAW_Temp74 varChar (32), '  +
       'PAW_Temp75 varChar (32), PAW_Temp76 varChar (32), '  +
       'PAW_Temp77 varChar (32), PAW_Temp78 varChar (32), '  +
       'PAW_Temp79 varChar (32), PAW_Temp80 varChar (32), '  +
       'PAW_Temp81 varChar (32), PAW_Temp82 varChar (32), '  +
       'PAW_Temp83 varChar (32), PAW_Temp84 varChar (32), '  +
       'PAW_Temp85 varChar (32), PAW_Temp86 varChar (32), '  +
       'PAW_Temp87 varChar (32), PAW_Temp88 varChar (32), '  +
       'PAW_Temp89 varChar (32), PAW_Temp90 varChar (32), '  +
       'PAW_Temp91 varChar (32), PAW_Temp92 varChar (32), '  +
       'PAW_Temp93 varChar (32), PAW_Temp94 varChar (32), '  +
       'PAW_Temp95 varChar (32), PAW_Temp96 varChar (32), '  +
       'PAW_Temp97 varChar (32), PAW_Temp98 varChar (32), '  +
       'PAW_Temp99 varChar (32), PAW_Temp100 varChar (32), '  +
       'PAW_Temp101 varChar (32), PAW_Temp102 varChar (32), '  +
       'PAW_Temp103 varChar (32), PAW_Temp104 varChar (32), '  +
       'PAW_Temp105 varChar (32), PAW_Temp106 varChar (32), '  +
       'PAW_Temp107 varChar (32), PAW_Temp108 varChar (32), '  +
       'PAW_Temp109 varChar (32), PAW_Temp110 varChar (32), '  +
       'PAW_Temp111 varChar (32), PAW_Temp112 varChar (32), '  +
       'PAW_Temp113 varChar (32), PAW_Temp114 varChar (32), '  +
       'PAW_Temp115 varChar (32), PAW_Temp116 varChar (32), '  +
       'PAW_Temp117 varChar (32), PAW_Temp118 varChar (32), '  +
       'PAW_Temp119 varChar (32), PAW_Temp120 varChar (32), '  +
       'PAW_Temp121 varChar (32), PAW_Temp122 varChar (32), '  +
       'PAW_Temp123 varChar (32), PAW_Temp124 varChar (32), '  +
       'PAW_Temp125 varChar (32), PAW_Temp126 varChar (32), '  +
       'PAW_Temp127 varChar (32), PAW_Temp128 varChar (32), '  +
       'PAW_Temp129 varChar (32), PAW_Temp130 varChar (32), '  +
       'PAW_Temp131 varChar (32), PAW_Temp132 varChar (32), '  +
       'PAW_Temp133 varChar (32), PAW_Temp134 varChar (32), '  +
       'PAW_Temp135 varChar (32), PAW_Temp136 varChar (32), '  +
       'PAW_Temp137 varChar (32), PAW_Temp138 varChar (32), '  +
       'PAW_Temp139 varChar (32), PAW_Temp0 varChar (32)'  +
       'PAW_Temp141 varChar (32), PAW_Temp143 varChar (32)'  +
       'PAW_Temp145 varChar (32)'  +
       ')';
  {-----------------------------------------------------------------------------
   ˮ�໯���¼��: YTBatchcode
   *.R_ID: ��¼���
   *.C_ID: �����¼
   *.C_Code: ˮ����
   *.C_Stock: Ʒ�ֱ��
   *.C_Freeze: ������
   *.C_HasDone: �����
  -----------------------------------------------------------------------------}

  sSQL_NewWebOrderMatch = 'Create Table $Table(R_ID $Inc,WOM_WebOrderID varchar(32) null,WOM_LID varchar(20) null,WOM_deleted char(1) default ''N'')';
  {-----------------------------------------------------------------------------
   �̳Ƕ�������������ձ�: WebOrderMatch
   *.R_ID: ��¼���
   *.WOM_WebOrderID: �̳Ƕ���
   *.WOM_LID: �����
  -----------------------------------------------------------------------------}

  sSQL_NewSpecialCustomerCementcode = 'Create Table $Table(R_ID $Inc,SCC_CusID varchar(20) null,SCC_ClientName varchar(80) null,SCC_Cementcode varchar(50))';
  {-----------------------------------------------------------------------------
   ����ͻ�ˮ���ű�: SpecialCustomerCementcode
   *.R_ID: ��¼���
   *.SCC_CusID: �ͻ����
   *.SCC_ClientName: �ͻ�����
   *.SCC_Cementcode: ˮ����
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// ���ݲ�ѯ
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo, D_ParamA, ' +
         'D_ParamB From $Table Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   �������ֵ��ȡ����
   *.$Table:�����ֵ��
   *.$Name:�ֵ�������
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
         'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   ����չ��Ϣ����ȡ����
   *.$Table:��չ��Ϣ��
   *.$Group:��������
   *.$ID:��Ϣ��ʶ
  -----------------------------------------------------------------------------}

function CardStatusToStr(const nStatus: string): string;
//�ſ�״̬
function TruckStatusToStr(const nStatus: string): string;
//����״̬
function BillTypeToStr(const nType: string): string;
//��������
function PostTypeToStr(const nPost: string): string;
//��λ����
function BusinessToStr(const nBus: string): string;
//ҵ������

implementation

//Desc: ��nStatusתΪ�ɶ�����
function CardStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_CardIdle then Result := '����' else
  if nStatus = sFlag_CardUsed then Result := '����' else
  if nStatus = sFlag_CardLoss then Result := '��ʧ' else
  if nStatus = sFlag_CardInvalid then Result := 'ע��' else Result := 'δ֪';
end;

//Desc: ��nStatusתΪ��ʶ�������
function TruckStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_TruckIn then Result := '����' else
  if nStatus = sFlag_TruckOut then Result := '����' else
  if nStatus = sFlag_TruckBFP then Result := '��Ƥ��' else
  if nStatus = sFlag_TruckBFM then Result := '��ë��' else
  if nStatus = sFlag_TruckSH then Result := '�ͻ���' else
  if nStatus = sFlag_TruckXH then Result := '���մ�' else
  if nStatus = sFlag_TruckFH then Result := '�ŻҴ�' else
  if nStatus = sFlag_TruckZT then Result := 'ջ̨' else Result := 'δ����';
end;

//Desc: ����������תΪ��ʶ������
function BillTypeToStr(const nType: string): string;
begin
  if nType = sFlag_TypeShip then Result := '����' else
  if nType = sFlag_TypeZT   then Result := 'ջ̨' else
  if nType = sFlag_TypeVIP  then Result := 'VIP' else Result := '��ͨ';
end;

//Desc: ����λתΪ��ʶ������
function PostTypeToStr(const nPost: string): string;
begin
  if nPost = sFlag_TruckIn   then Result := '��������' else
  if nPost = sFlag_TruckOut  then Result := '��������' else
  if nPost = sFlag_TruckBFP  then Result := '������Ƥ' else
  if nPost = sFlag_TruckBFM  then Result := '��������' else
  if nPost = sFlag_TruckFH   then Result := 'ɢװ�Ż�' else
  if nPost = sFlag_TruckZT   then Result := '��װջ̨' else Result := '����';
end;

//Desc: ҵ������תΪ��ʶ������
function BusinessToStr(const nBus: string): string;
begin
  if nBus = sFlag_Sale       then Result := '����' else
  if nBus = sFlag_Provide    then Result := '��Ӧ' else
  if nBus = sFlag_Returns    then Result := '�˻�' else
  if nBus = sFlag_DuanDao    then Result := '�̵�' else
  //if nBus = sFlag_WaiXie     then Result := '��Э' else
  if nBus = sFlag_Other      then Result := '����';
end;

//------------------------------------------------------------------------------
//Desc: ����ϵͳ����
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: ϵͳ��
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);

  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);
  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch);
  AddSysTableItem(sTable_WorkePC, sSQL_NewWorkePC);

  AddSysTableItem(sTable_Customer, sSQL_NewCustomer);
  AddSysTableItem(sTable_Salesman, sSQL_NewSalesMan);
  AddSysTableItem(sTable_Translator, sSQL_NewTranslator);
  AddSysTableItem(sTable_SaleContract, sSQL_NewSaleContract);
  AddSysTableItem(sTable_SContractExt, sSQL_NewSContractExt);

  AddSysTableItem(sTable_CusAccount, sSQL_NewCusAccount);
  AddSysTableItem(sTable_InOutMoney, sSQL_NewInOutMoney);
  AddSysTableItem(sTable_CusCredit, sSQL_NewCusCredit);
  AddSysTableItem(sTable_SysShouJu, sSQL_NewSysShouJu);

  AddSysTableItem(sTable_InvoiceWeek, sSQL_NewInvoiceWeek);
  AddSysTableItem(sTable_Invoice, sSQL_NewInvoice);
  AddSysTableItem(sTable_InvoiceDtl, sSQL_NewInvoiceDtl);
  AddSysTableItem(sTable_InvoiceReq, sSQL_NewInvoiceReq);
  AddSysTableItem(sTable_InvReqtemp, sSQL_NewInvoiceReq);
  AddSysTableItem(sTable_DataTemp, sSQL_NewDataTemp);

  AddSysTableItem(sTable_WeixinLog, sSQL_NewWXLog);
  AddSysTableItem(sTable_WeixinMatch, sSQL_NewWXMatch);
  AddSysTableItem(sTable_WeixinTemp, sSQL_NewWXTemplate);
  AddSysTableItem(sTable_WeixinBind,sSQL_NewWeixinCusBind);

  AddSysTableItem(sTable_ZhiKa, sSQL_NewZhiKa);
  AddSysTableItem(sTable_ZhiKaDtl, sSQL_NewZhiKaDtl);
  AddSysTableItem(sTable_Card, sSQL_NewCard);
  AddSysTableItem(sTable_Bill, sSQL_NewBill);
  AddSysTableItem(sTable_BillBak, sSQL_NewBill);
  AddSysTableItem(sTable_Order, sSQL_NewOrder);
  AddSysTableItem(sTable_OrderBak, sSQL_NewOrder);
  AddSysTableItem(sTable_OrderBase, sSQL_NewOrderBase);
  AddSysTableItem(sTable_OrderBaseBak, sSQL_NewOrderBase);
  AddSysTableItem(sTable_OrderDtl, sSQL_NewOrderDtl);
  AddSysTableItem(sTable_OrderDtlBak, sSQL_NewOrderDtl);

  AddSysTableItem(sTable_TransBase, sSQL_NewTransBase);
  AddSysTableItem(sTable_TransBaseBak, sSQL_NewTransBase);
  AddSysTableItem(sTable_Transfer, sSQL_NewTransfer);
  AddSysTableItem(sTable_TransferBak, sSQL_NewTransfer);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines);
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks);
  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);
  AddSysTableItem(sTable_Picture, sSQL_NewPicture);
  AddSysTableItem(sTable_Provider, ssql_NewProvider);
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails);

  AddSysTableItem(sTable_StockParam, sSQL_NewStockParam);
  AddSysTableItem(sTable_StockParamExt, sSQL_NewStockRecord);
  AddSysTableItem(sTable_StockRecord, sSQL_NewStockRecord);
  AddSysTableItem(sTable_StockHuaYan, sSQL_NewStockHuaYan);

  AddSysTableItem(sTable_YT_CardInfo, sSQL_NewYTCard);
  AddSysTableItem(sTable_YT_CodeInfo, sSQL_NewYTCode);
  AddSysTableItem(sTable_YT_Batchcode, sSQL_NewYTBatchcode);
  AddSysTableItem(sTable_WebOrderMatch,sSQL_NewWebOrderMatch);
  AddSysTableItem(sTable_SpecialCustomerCementcode,sSQL_NewSpecialCustomerCementcode);
end;

//Desc: ����ϵͳ��
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.

