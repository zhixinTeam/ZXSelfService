{*******************************************************************************
  作者: 289525016@163.com 2017-3-30
  描述: 自助办卡窗口--葛洲坝钟祥水泥有限公司
*******************************************************************************}
unit uZXNewCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Uszttce_api,Contnrs;

type

  TfFormNewCard = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditValue: TcxTextEdit;
    EditCard: TcxTextEdit;
    EditID: TcxTextEdit;
    EditCus: TcxTextEdit;
    EditCName: TcxTextEdit;
    EditStock: TcxTextEdit;
    EditSName: TcxTextEdit;
    EditMax: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    EditType: TcxComboBox;
    PrintFH: TcxCheckBox;
    EditFQ: TcxButtonEdit;
    EditGroup: TcxComboBox;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxGroupLayout1Group2: TdxLayoutGroup;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxlytmLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxlytmLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item10: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Item11: TdxLayoutItem;
    dxlytmLayout1Item11: TdxLayoutItem;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayout1Item7: TdxLayoutItem;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    EditHd: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditHdValue: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure lvOrdersClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    FSzttceApi:TSzttceApi; //发卡机驱动
    FAutoClose:Integer; //窗口自动关闭倒计时（分钟）
    FWebOrderIndex:Integer; //商城订单索引
    FWebOrderItems:array of stMallOrderItem; //商城订单数组
    FCardData,FHdCardData:TStrings; //云天系统返回的大票号信息
    FHdJiaoYan:Boolean;//袋装拼单校验结果
    Fbegin:TDateTime;
    FLastClick: Int64;
    procedure InitListView;
    procedure SetControlsReadOnly;
    function DownloadOrder(const nCard:string):Boolean;
    procedure Writelog(nMsg:string);
    procedure AddListViewItem(var nWebOrderItem:stMallOrderItem);
    procedure LoadSingleOrder;
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    function CheckYunTianOrderInfo(const nOrderId:string;var nWebOrderItem:stMallOrderItem):Boolean;
    function CheckYunTianOrderHdInfo(const nHdOrderId:string; var nWebOrderItem:stMallOrderItem):Boolean;
    function do_YT_GetBatchCode(const nWebOrderItem:stMallOrderItem):Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    function SaveBillProxy:Boolean;
    function SaveWebOrderMatch(const nBillID,nWebOrderID:string):Boolean;
  public
    { Public declarations }
    procedure SetControlsClear;
    property SzttceApi:TSzttceApi read FSzttceApi write FSzttceApi;
  end;

var
  fFormNewCard: TfFormNewCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormBase,UDataReport,UDataModule,NativeXml,UMgrK720Reader,UFormWait,
  DateUtils;
{$R *.dfm}

{ TfFormNewCard }

procedure TfFormNewCard.SetControlsClear;
var
  i:Integer;
  nComp:TComponent;
begin
  editWebOrderNo.Clear;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Clear;
    end;
  end;
end;
procedure TfFormNewCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FCardData.Free;
  FHdCardData.Free;
  Action:=  caFree;
  fFormNewCard := nil;
end;

procedure TfFormNewCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  dxLayout1Item5.Visible := False;
  dxLayout1Item9.Visible := False;
  dxlytmLayout1Item13.Visible := False;
  dxLayout1Item12.Visible := False;
  EditTruck.Properties.Buttons[0].Visible := False;
  ActiveControl := editWebOrderNo;
  btnOK.Enabled := False;
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
  EditFQ.Properties.Buttons[0].Visible := False; 
end;

procedure TfFormNewCard.SetControlsReadOnly;
var
  i:Integer;
  nComp:TComponent;
begin
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Properties.ReadOnly := True;
    end;
  end;
  EditFQ.Properties.ReadOnly := True;
end;

procedure TfFormNewCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewCard.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '请先输入或扫描订单号';
      ShowMsg(nStr,sHint);
      Writelog(nStr);
      Exit;
    end;
    lvOrders.Items.Clear;
    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

function TfFormNewCard.DownloadOrder(const nCard: string): Boolean;
var
  nXmlStr,nData:string;
  nListA,nListB:TStringList;
  i:Integer;
  nWebOrderCount:Integer;
begin
  Result := False;
  FWebOrderIndex := 0;
  
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'      <NO>%s</NO>'
            +'      <status>-1</status>'  //-1  开卡    0  开卡成功
            +'</head>'
            +'</DATA>';

  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nCard]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  FBegin := Now;
  nData := get_shoporderbyno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('未查询到网上商城订单详细信息，请检查订单号是否正确',sHint);
    Writelog('未查询到网上商城订单详细信息，请检查订单号是否正确');
    Exit;
  end;
  Writelog('TfFormNewCard.DownloadOrder(nCard='''+nCard+''') 查询商城订单-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  //解析网城订单信息
  nData := PackerDecodeStr(nData);
  Writelog('get_shoporderbyno res:'+nData);
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := nData;
    for i := nListA.Count-1 downto 0 do
    begin
      if Trim(nListA.Strings[i])='' then
      begin
        nListA.Delete(i);
      end;
    end;

    nWebOrderCount := nListA.Count;
    SetLength(FWebOrderItems,nWebOrderCount);
    for i := 0 to nWebOrderCount-1 do
    begin
      nListB.CommaText := nListA.Strings[i];
      FWebOrderItems[i].FOrder_id := nListB.Values['order_id'];
      FWebOrderItems[i].FOrdernumber := nListB.Values['ordernumber'];
      FWebOrderItems[i].FGoodsID := nListB.Values['goodsID'];
      FWebOrderItems[i].FGoodstype := nListB.Values['goodstype'];
      FWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
      FWebOrderItems[i].FData := nListB.Values['data'];
      FWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
      FWebOrderItems[i].FYunTianOrderId := nListB.Values['fac_order_no'];
      FWebOrderItems[i].FHd_Order_no := nListB.Values['hd_fac_order_no'];
      FWebOrderItems[i].Fspare := nListB.Values['spare'];
      AddListViewItem(FWebOrderItems[i]);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
  LoadSingleOrder;
end;

procedure TfFormNewCard.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]clientid[%s]clientname[%s]sotckno[%s]stockname[%s]';
  nStr := Format(nStr,[editWebOrderNo.Text,EditCus.Text,EditCName.Text,EditStock.Text,EditSName.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

procedure TfFormNewCard.AddListViewItem(
  var nWebOrderItem: stMallOrderItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrdernumber;

  nlistitem.SubItems.Add(nWebOrderItem.FGoodsID);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
end;

procedure TfFormNewCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '网上订单编号';
  col.Width := 300;
  col := lvOrders.Columns.Add;
  col.Caption := '水泥型号';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '水泥名称';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '提货车辆';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '办理吨数';
  col.Width := 150;
end;

procedure TfFormNewCard.FormCreate(Sender: TObject);
begin
  editWebOrderNo.Properties.MaxLength := gSysParam.FWebOrderLength;
  FCardData := TStringList.Create;
  FHdCardData := TStringList.Create;
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  InitListView;
  gSysParam.FUserID := 'AICM';
end;

procedure TfFormNewCard.LoadSingleOrder;
var
  nOrderItem:stMallOrderItem;
  nRepeat:Boolean;
  nWebOrderID:string;
  nMsg:string;
begin
  FHdJiaoYan := False;
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrdernumber;

  FBegin := Now;
  nRepeat := IsRepeatCard(nWebOrderID);

  if nRepeat then
  begin
    nMsg := '此订单已成功办卡，请勿重复操作';
    ShowMsg(nMsg,sHint);
    Writelog(nMsg);
    Exit;
  end;
  writelog('TfFormNewCard.LoadSingleOrder 检查商城订单是否重复使用-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  //订单有效性校验
  FBegin := Now;
  if not CheckYunTianOrderInfo(nOrderItem.FYunTianOrderId, nOrderItem) then
  begin
    BtnOK.Enabled := False;
    Exit;
  end;

  if (nOrderItem.FHd_Order_No <> '-1') and (Pos('袋',nOrderItem.FGoodsname) > 0) then
  begin
    if CheckYunTianOrderHdInfo(nOrderItem.FHd_Order_No, nOrderItem) then FHdJiaoYan := True;
  end;
  writelog('TfFormNewCard.LoadSingleOrder 订单有效性校验-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

  //填充界面信息
  //基本信息
  EditID.Text     := FCardData.Values['XCB_ID'];
  EditCard.Text   := FCardData.Values['XCB_CardId'];
  EditCus.Text    := FCardData.Values['XCB_Client'];
  EditCName.Text  := FCardData.Values['XCB_ClientName'];

  //提单信息
  EditType.ItemIndex := 0;
  EditStock.Text  := FCardData.Values['XCB_Cement'];
  EditSName.Text  := FCardData.Values['XCB_CementName'];
  EditMax.Text    := FCardData.Values['XCB_RemainNum'];
  EditValue.Text := nOrderItem.FData;
  EditTruck.Text := nOrderItem.Ftracknumber;
  EditHd.Text    := nOrderItem.FHd_Order_No;
  EditHdValue.Text:= nOrderItem.Fspare;

  if gSysParam.FShuLiaoNeedBatchCode then
  begin
    FBegin := Now;
    if not do_YT_GetBatchCode(nOrderItem) then
    begin
      nMsg := '获取出厂编号失败。';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg);
      BtnOK.Enabled := False;
      Exit;
    end;
    writelog('TfFormNewCard.LoadSingleOrder 获取出厂编号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    EditFQ.Text := FCardData.Values['XCB_CementCode'];
  end;
  BtnOK.Enabled := not nRepeat;
end;

function TfFormNewCard.IsRepeatCard(const nWebOrderItem: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where WOM_WebOrderID=''%s'' and WOM_deleted=''%s''';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderItem,sFlag_No]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewCard.CheckYunTianOrderInfo(const nOrderId: string;
  var nWebOrderItem: stMallOrderItem): Boolean;
var
  nCardDataStr: string;
  nIn: TWorkerBusinessCommand;
  nOut: TWorkerBusinessCommand;
  nYuntianOrderItem:stMallOrderItem;
  nMsg:string;
  nOrderNumberWeb,nOrderNumberYT:Double;
begin
  Result := False;
  FCardData.Clear;

  nCardDataStr := nOrderId;
  if not (YT_ReadCardInfo(nCardDataStr) and YT_VerifyCardInfo(nCardDataStr)) then
  begin
    ShowMsg(nCardDataStr,sHint);
    Writelog(nCardDataStr);
    Exit;
  end;

  FCardData.Text := PackerDecodeStr(nCardDataStr);

  nYuntianOrderItem.FGoodsID := FCardData.Values['XCB_Cement'];
  nYuntianOrderItem.FGoodsname := FCardData.Values['XCB_CementName'];
  nYuntianOrderItem.FOrdernumber := FCardData.Values['XCB_RemainNum'];
  nYuntianOrderItem.FCusID := FCardData.Values['XCB_Client'];
  nYuntianOrderItem.FCusName := FCardData.Values['XCB_ClientName'];

  if nWebOrderItem.FGoodsID<>nYuntianOrderItem.FGoodsID then
  begin
    nMsg := '商城订单中产品型号[%s]有误。';
    nMsg := Format(nMsg,[nWebOrderItem.FGoodsID]);
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;

  if nWebOrderItem.FGoodsname<>nYuntianOrderItem.FGoodsname then
  begin
    nMsg := '商城订单中产品名称[%s]有误。';
    nMsg := Format(nMsg,[nWebOrderItem.FGoodsname]);
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;

  nOrderNumberWeb := StrToFloatDef(nWebOrderItem.FData,0);
  nOrderNumberYT := StrToFloatDef(nYuntianOrderItem.FOrdernumber,0);

  if (nOrderNumberWeb<=0.00001) or (nOrderNumberYT<=0.00001) then
  begin
    nMsg := '订单中提货数量格式有误。';
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;

  if nOrderNumberWeb-nOrderNumberYT>0.00001 then
  begin
    nMsg := '商城订单中提货数量有误，最多可提货数量为[%f]。';
    nMsg := Format(nMsg,[nOrderNumberYT]);
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;
  Result := True;  
end;

function TfFormNewCard.CheckYunTianOrderHdInfo(const nHdOrderId:string; var nWebOrderItem:stMallOrderItem):Boolean;
var
  nCardDataStr: string;
  nIn: TWorkerBusinessCommand;
  nOut: TWorkerBusinessCommand;
  nYuntianOrderItem:stMallOrderItem;
  nMsg:string;
  nOrderNumberWeb,nOrderNumberYT:Double;
begin
  Result := False;
  FHdCardData.Clear;

  nCardDataStr := nHdOrderId;
  if not (YT_ReadCardInfo(nCardDataStr) and YT_VerifyCardInfo(nCardDataStr)) then
  begin
    ShowMsg(nCardDataStr,sHint);
    Writelog(nCardDataStr);
    Exit;
  end;

  FHdCardData.Text := PackerDecodeStr(nCardDataStr);

  with nYuntianOrderItem, FHdCardData do
  begin
    FGoodsID := Values['XCB_Cement'];
    FGoodsname := Values['XCB_CementName'];
    FOrdernumber := Values['XCB_RemainNum'];
    FCusID := Values['XCB_Client'];
    FCusName := Values['XCB_ClientName'];
  end;

  if nWebOrderItem.FGoodsID<>nYuntianOrderItem.FGoodsID then
  begin
    nMsg := '商城订单中拼单产品型号[%s]有误。';
    nMsg := Format(nMsg,[nWebOrderItem.FGoodsID]);
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;

  if nWebOrderItem.FGoodsname<>nYuntianOrderItem.FGoodsname then
  begin
    nMsg := '商城订单中拼单产品名称[%s]有误。';
    nMsg := Format(nMsg,[nWebOrderItem.FGoodsname]);
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;

  nOrderNumberWeb := StrToFloatDef(nWebOrderItem.Fspare,0);
  nOrderNumberYT := StrToFloatDef(nYuntianOrderItem.FOrdernumber,0);

  if (nOrderNumberWeb<=0.00001) or (nOrderNumberYT<=0.00001) then
  begin
    nMsg := '订单中拼单提货数量格式有误。';
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;

  if nOrderNumberWeb-nOrderNumberYT>0.00001 then
  begin
    nMsg := '商城订单中拼单提货数量有误，最多可提货数量为[%f]。';
    nMsg := Format(nMsg,[nOrderNumberYT]);
    ShowMsg(nMsg,sError);
    Writelog(nMsg);
    Exit;
  end;
  Result := True;  
end;

function TfFormNewCard.do_YT_GetBatchCode(
  const nWebOrderItem: stMallOrderItem): Boolean;
var
  nInList,nOutList:TStrings;
  nData:string;
  nIdx:Integer;
  nCementRecords:TStrings;
  nCementRecordItem:TStrings;
  nCementValue,nOrderValue:Double;
begin
  Result := False;
  nOrderValue := StrToFloat(nWebOrderItem.FData);
  nInList := TStringList.Create;
  nOutList := TStringList.Create;
  nCementRecords := TStringList.Create;
  nCementRecordItem := TStringList.Create;
  try
    nInList.Values['XCB_Cement'] := nWebOrderItem.FGoodsID;
    nInList.Values['Value'] := nWebOrderItem.FData;
    nOutList.Text := YT_GetBatchCode(nInList);

    if (nOutList.Values['XCB_CementCode']='')
      or (nOutList.Values['XCB_CementCodeID']='') then Exit;
    FCardData.Values['XCB_CementCode'] := nOutList.Values['XCB_CementCode'];
    FCardData.Values['XCB_CementCodeID'] := nOutList.Values['XCB_CementCodeID'];

    nCementRecords.Text := PackerDecodeStr(nOutList.Values['XCB_CementRecords']);
    for nIdx := 0 to nCementRecords.Count - 1 do
    begin
      nCementRecordItem.Text := PackerDecodeStr(nCementRecords[nIdx]);
      nCementValue := StrToFloatDef(nCementRecordItem.Values['XCB_CementValue'],0);
      if nCementValue-nOrderValue>0.00001 then
      begin
        FCardData.Values['XCB_CementCode'] := nCementRecordItem.Values['XCB_CementCode'];
        FCardData.Values['XCB_CementCodeID'] := nCementRecordItem.Values['XCB_CementCodeID'];
        Break;
      end;
    end;
    Result := True;
  finally
    nCementRecordItem.Free;
    nCementRecords.Free;
    nOutList.Free;
    nInList.Free;
  end;
end;

function TfFormNewCard.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    if not Result then
    begin
      nHint := '车牌号长度应大于2位';
      Writelog(nHint);
      Exit;
    end;

    Result := TruckmultipleCard(EditTruck.Text,nHint);
    if not Result then
    begin
      Writelog(nHint);
      Exit;
    end;
  end;
  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    if not Result then
    begin
      nHint := '请填写有效的办理量';
      Writelog(nHint);
      Exit;
    end;

    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, StrToFloat(EditMax.Text),rtLE);
    if not Result then
    begin
      nHint := '已超出可提货量';
      Writelog(nHint);
    end;
  end;
end;

procedure TfFormNewCard.BtnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then Exit;
    Close;
  finally
    BtnOK.Enabled := True;
  end;
end;

function TfFormNewCard.SaveBillProxy: Boolean;
var
  nHint:string;
  nList,nTmp,nStocks: TStrings;
  nPrint,nInFact:Boolean;
  nBillData:string;
  nBillID,nHdBillID :string;
  nWebOrderID:string;
  nNewCardNo:string;
  nidx:Integer;
  i,j:Integer;
  nRet: Boolean;
begin
  Result := False;
  nWebOrderID := editWebOrderNo.Text;
  //校验提货单信息
  if EditID.Text='' then
  begin
    ShowMsg('未查询网上订单',sHint);
    Writelog('未查询网上订单');
    Exit;
  end;

  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  if gSysParam.FShuLiaoNeedBatchCode then
  begin
    if EditFQ.Text='' then
    begin
      ShowMsg('出厂编号无效',sHint);
      Writelog('出厂编号无效');
      Exit;
    end;
  end;

  if gSysParam.FCanCreateCard then
  begin
    nNewCardNo := '';
    Fbegin := Now;
  
    //连续三次读卡均失败，则回收卡片，重新发卡
    for i := 0 to 3 do
    begin
      for nIdx:=0 to 3 do
      begin
        if gMgrK720Reader.ReadCard(nNewCardNo) then Break;
        //连续三次读卡,成功则退出。
      end;
      if nNewCardNo<>'' then Break;
      gMgrK720Reader.RecycleCard;
    end;

    if nNewCardNo = '' then
    begin
      ShowDlg('卡箱异常,请查看是否有卡.', sWarn, Self.Handle);
      Exit;
    end;
    Writelog('ReadCard: ' + nNewCardNo);
    nNewCardNo := gMgrK720Reader.ParseCardNO(nNewCardNo);
    WriteLog('ParseCardNO: ' + nNewCardNo);
    if nNewCardNo = '' then
    begin
      ShowDlg('卡号异常,解析失败.', sWarn, Self.Handle);
      Exit;
    end;
    //解析卡片
    writelog('TfFormNewCard.SaveBillProxy 发卡机读卡-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  end;

  //验证是否已经保存提货单
  nRet := IFSaveBill(nWebOrderID, nBillID);

  //保存提货单
  if not nRet then
  begin
    nStocks := TStringList.Create;
    nList := TStringList.Create;
    nTmp := TStringList.Create;
    try
      LoadSysDictItem(sFlag_PrintBill, nStocks);

      nTmp.Values['Type'] := FCardData.Values['XCB_CementType'];
      nTmp.Values['StockNO'] := FCardData.Values['XCB_Cement'];
      nTmp.Values['StockName'] := FCardData.Values['XCB_CementName'];
      nTmp.Values['Price'] := '0.00';
      nTmp.Values['Value'] := EditValue.Text;

      nList.Add(PackerEncodeStr(nTmp.Text));
      nPrint := nStocks.IndexOf(FCardData.Values['XCB_Cement']) >= 0;

      with nList do
      begin
        Values['Bills'] := PackerEncodeStr(nList.Text);
        Values['ZhiKa'] := PackerEncodeStr(FCardData.Text);
        Values['Truck'] := EditTruck.Text;
        Values['Lading'] := sFlag_TiHuo;
        Values['LineGroup'] := GetCtrlData(EditGroup);
        Values['Memo']  := EmptyStr;
        Values['IsVIP'] := Copy(GetCtrlData(EditType),1,1);
        Values['Seal'] := FCardData.Values['XCB_CementCodeID'];
        Values['HYDan'] := EditFQ.Text;
        Values['WebOrderID'] := nWebOrderID;
        Values['HdOrderId'] := EditHd.Text;
        if PrintFH.Checked  then Values['PrintFH'] := sFlag_Yes;
      end;
      nBillData := PackerEncodeStr(nList.Text);
      FBegin := Now;
      nBillID := SaveBill(nBillData);
      if nBillID = '' then Exit;
      writelog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
      FBegin := Now;
      SaveWebOrderMatch(nBillID,nWebOrderID);
      writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    finally
      nStocks.Free;
      nList.Free;
      nTmp.Free;
    end;
  end;

  nRet := SaveBillCard(nBillID,nNewCardNo);
  ShowMsg('提货单保存成功', sHint);
  FBegin := Now;
  
  if nRet then
  begin
    nRet := False;
    for nIdx := 0 to 3 do
    begin
      nRet := gMgrK720Reader.SendReaderCmd('FC0');
      if nRet then Break;
    end;
    //发卡
  end;
  if nRet then
  begin
    nHint := '商城订单号['+editWebOrderNo.Text+']发卡成功,卡号['+nNewCardNo+'],请收好您的卡片';
    WriteLog(nHint);
    ShowMsg(nHint,sWarn);
  end
  else begin
    gMgrK720Reader.RecycleCard;

    nHint := '商城订单号['+editWebOrderNo.Text+'],卡号['+nNewCardNo+']关联订单失败，请到开票窗口重新关联。';
    WriteLog(nHint);
    ShowDlg(nHint,sHint,Self.Handle);
    Close;
  end;
  writelog('TfFormNewCard.SaveBillProxy 发卡机出卡并关联磁卡号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

  if FHdJiaoYan then
  begin
    nStocks := TStringList.Create;
    nList := TStringList.Create;
    nTmp := TStringList.Create;
    try
      LoadSysDictItem(sFlag_PrintBill, nStocks);

      nTmp.Values['Type'] := FHdCardData.Values['XCB_CementType'];
      nTmp.Values['StockNO'] := FHdCardData.Values['XCB_Cement'];
      nTmp.Values['StockName'] := FHdCardData.Values['XCB_CementName'];
      nTmp.Values['Price'] := '0.00';
      nTmp.Values['Value'] := EditHdValue.Text;

      nList.Add(PackerEncodeStr(nTmp.Text));
      nPrint := nStocks.IndexOf(FHdCardData.Values['XCB_Cement']) >= 0;

      with nList do
      begin
        Values['Bills'] := PackerEncodeStr(nList.Text);
        Values['ZhiKa'] := PackerEncodeStr(FHdCardData.Text);
        Values['Truck'] := EditTruck.Text;
        Values['Lading'] := sFlag_TiHuo;
        Values['LineGroup'] := GetCtrlData(EditGroup);
        Values['Memo']  := EmptyStr;
        Values['IsVIP'] := Copy(GetCtrlData(EditType),1,1);
        Values['Seal'] := FHdCardData.Values['XCB_CementCodeID'];
        Values['HYDan'] := EditFQ.Text;
        Values['WebOrderID'] := nWebOrderID;
        if PrintFH.Checked  then Values['PrintFH'] := sFlag_Yes;
      end;
      nBillData := PackerEncodeStr(nList.Text);
      FBegin := Now;
      nHdBillID := SaveBill(nBillData);
      if nHdBillID = '' then Exit;
      writelog('TfFormNewCard.SaveBillProxy 生成拼单提货单['+nHdBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
      FBegin := Now;
      SaveWebOrderMatch(nHdBillID,nWebOrderID);
      writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    finally
      nStocks.Free;
      nList.Free;
      nTmp.Free;
    end;

    if SaveBillCard(nHdBillID,nNewCardNo) then
    begin
      ShowMsg('拼单提货单关联磁卡成功', sHint);
      Writelog('拼单提货单[' + nHdBillID +'关联磁卡号[' + nNewCardNo +']成功');
    end else
    begin
      ShowMsg('拼单提货单关联磁卡失败', sHint);
      Writelog('拼单提货单[' + nHdBillID +'关联磁卡号[' + nNewCardNo +']失败');
    end;
  end;

  if nPrint then
    PrintBillReport(nBillID, True);
  //print report

  if IFPrintFYD then
    PrintBillFYDReport(nBillID, True);

  if nRet then Close;
end;

function TfFormNewCard.SaveWebOrderMatch(const nBillID,
  nWebOrderID: string):Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID) values(''%s'',''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderID,nBillID]);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
    Result := True;
  except
    fdm.ADOConn.RollbackTrans;
  end;
end;
procedure TfFormNewCard.lvOrdersClick(Sender: TObject);
var
  nSelItem:TListItem;
  i:Integer;
begin
  if (GetTickCount - FLastClick < 3 * 1000) then
  begin
    ShowMsg('请不要频繁点击！', sHint);
    Exit;
  end;
  
  nSelItem := lvorders.Selected;
  if Assigned(nSelItem) then
  begin
    for i := 0 to lvOrders.Items.Count-1 do
    begin
      if nSelItem = lvOrders.Items[i] then
      begin
        FWebOrderIndex := i;
        LoadSingleOrder;
        Break;
      end;
    end;
  end;
  FLastClick := GetTickCount;
end;

procedure TfFormNewCard.editWebOrderNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    btnQuery.SetFocus;
    btnQuery.Click;
  end;
end;

procedure TfFormNewCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

end.
