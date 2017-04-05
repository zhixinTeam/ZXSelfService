{*******************************************************************************
  ����: 289525016@163.com 2017-3-31
  ����: �����쿨����--���ް�����ˮ�����޹�˾
*******************************************************************************}
unit uZXNewPurchaseCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Uszttce_api,Contnrs;

type
  TfFormNewPurchaseCard = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditValue: TcxTextEdit;
    EditProv: TcxTextEdit;
    EditID: TcxTextEdit;
    EditProduct: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxGroupLayout1Group2: TdxLayoutGroup;
    dxLayoutGroup2: TdxLayoutGroup;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    dxLayout1Group1: TdxLayoutGroup;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSzttceApi:TSzttceApi; //����������
    FAutoClose:Integer; //�����Զ��رյ���ʱ�����ӣ�
    FWebOrderIndex:Integer; //�̳Ƕ�������
    FWebOrderItems:array of stMallPurchaseItem; //�̳Ƕ�������
    FMaxQuantity:Double; //��ͬʣ����
    procedure InitListView;
    procedure SetControlsReadOnly;
    procedure Writelog(nMsg:string);
    function DownloadOrder(const nCard:string):Boolean;
    procedure AddListViewItem(var nWebOrderItem:stMallPurchaseItem);
    procedure LoadSingleOrder;
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    function CheckOrderValidate(var nWebOrderItem:stMallPurchaseItem):Boolean;
    function SaveBillProxy:Boolean;
    function SaveWebOrderMatch(const nBillID,nWebOrderID:string):Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
  public
    { Public declarations }
    procedure SetControlsClear;
    property SzttceApi:TSzttceApi read FSzttceApi write FSzttceApi;
  end;

var
  fFormNewPurchaseCard: TfFormNewPurchaseCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormCard,UFormBase,UDataReport,UDataModule,NativeXml;
{$R *.dfm}

{ TfFormNewPurchaseCard }

procedure TfFormNewPurchaseCard.SetControlsClear;
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

procedure TfFormNewPurchaseCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewPurchaseCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=  caFree;
  fFormNewPurchaseCard := nil;
  fFormMain.TimerInsertCard.Enabled := True;
end;

procedure TfFormNewPurchaseCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

procedure TfFormNewPurchaseCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  EditTruck.Properties.Buttons[0].Visible := False;
  
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
end;

procedure TfFormNewPurchaseCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewPurchaseCard.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '���������ɨ�������';
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

procedure TfFormNewPurchaseCard.BtnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then Exit;
    Close;
  finally
    BtnOK.Enabled := True;
  end;
end;

procedure TfFormNewPurchaseCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '�̳ǻ������';
  col.Width := 170;

  col := lvOrders.Columns.Add;
  col.Caption := '��ͬ���';
  col.Width := 150;

  col := lvOrders.Columns.Add;
  col.Caption := '��������';
  col.Width := 200;

  col := lvOrders.Columns.Add;
  col.Caption := '��������';
  col.Width := 200;

  col := lvOrders.Columns.Add;
  col.Caption := '�������';
  col.Width := 150;
end;

procedure TfFormNewPurchaseCard.SetControlsReadOnly;
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
end;

procedure TfFormNewPurchaseCard.FormCreate(Sender: TObject);
begin
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;

  InitListView;
  gSysParam.FUserID := 'AICM';
end;

procedure TfFormNewPurchaseCard.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]contractcode[%s]provname[%s]productname[%s]:';
  nStr := Format(nStr,[editWebOrderNo.Text,EditID.Text,EditProv.Text,EditProduct.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

function TfFormNewPurchaseCard.DownloadOrder(const nCard: string): Boolean;
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
            +'<NO>%s</NO>'
            +'</head>'
            +'</DATA>';

  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nCard]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nData := get_shopPurchaseByno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('δ��ѯ�������̳ǻ�����ϸ��Ϣ������������Ƿ���ȷ',sHint);
    Writelog('δ��ѯ�������̳ǻ�����ϸ��Ϣ������������Ƿ���ȷ');
    Exit;
  end;

  //�������Ƕ�����Ϣ
  nData := PackerDecodeStr(nData);
  Writelog('get_shopPurchaseByno res:'+nData);
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
      FWebOrderItems[i].Fpurchasecontract_no := nListB.Values['ordernumber'];
      FWebOrderItems[i].FgoodsID := nListB.Values['goodsID'];
      FWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
      FWebOrderItems[i].FData := nListB.Values['data'];
      FWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
      AddListViewItem(FWebOrderItems[i]);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
  LoadSingleOrder;
end;

procedure TfFormNewPurchaseCard.AddListViewItem(
  var nWebOrderItem: stMallPurchaseItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrder_id;

  nlistitem.SubItems.Add(nWebOrderItem.Fpurchasecontract_no);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
end;

procedure TfFormNewPurchaseCard.LoadSingleOrder;
var
  nOrderItem:stMallPurchaseItem;
  nRepeat:Boolean;
  nWebOrderID:string;
  nMsg:string;
begin
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrder_id;
  nRepeat := IsRepeatCard(nWebOrderID);

  if nRepeat then
  begin
    nMsg := '�˻����ѳɹ��쿨�������ظ�����';
    ShowMsg(nMsg,sHint);
    Writelog(nMsg);
    Exit;
  end;

  //������Ч��У��
  if not CheckOrderValidate(nOrderItem) then
  begin
    BtnOK.Enabled := False;
    Exit;
  end;

  //��������Ϣ
  //������Ϣ
  EditID.Text := nOrderItem.Fpurchasecontract_no;
  EditProv.Text := nOrderItem.FProvName;
  EditProduct.Text := nOrderItem.FGoodsname;
  //������Ϣ
  EditTruck.Text := nOrderItem.Ftracknumber;
  EditValue.Text := nOrderItem.FData;

  FWebOrderItems[FWebOrderIndex] := nOrderItem;
  BtnOK.Enabled := not nRepeat;
end;

function TfFormNewPurchaseCard.IsRepeatCard(
  const nWebOrderItem: string): Boolean;
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

function TfFormNewPurchaseCard.CheckOrderValidate(var nWebOrderItem: stMallPurchaseItem): Boolean;
var
  nStr:string;
  nwebOrderValue:Double;
  nMsg:string;
begin
  Result := False;
  nStr := 'Select *,con_quantity-con_finished_quantity as con_remain_quantity From %s where con_status>0 and pcId=''%s''';
  nStr := Format(nStr,[sTable_PurchaseContract,nWebOrderItem.Fpurchasecontract_no]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount<=0 then
    begin
      nMsg := '�ɹ���ͬ��������ɹ���ͬ�ѱ�ɾ��[%s]��';
      nMsg := Format(nMsg,[nWebOrderItem.Fpurchasecontract_no]);
      ShowMsg(nMsg,sError);
      Writelog(nMsg);
      Exit;
    end;

    nWebOrderItem.FProvID := FieldByName('provider_code').AsString;
    nWebOrderItem.FProvName := FieldByName('provider_name').AsString;

    if nWebOrderItem.FGoodsID<>FieldByName('con_materiel_Code').AsString then
    begin
      nMsg := '�̳ǻ�����ԭ����[%s]����';
      nMsg := Format(nMsg,[nWebOrderItem.FGoodsname]);
      ShowMsg(nMsg,sError);
      Writelog(nMsg);
      Exit;
    end;

    nwebOrderValue := StrToFloatDef(nWebOrderItem.FData,0);
    FMaxQuantity := FieldByName('con_remain_quantity').AsFloat;

//    if (nwebOrderValue<=0.00001) then
//    begin
//      nMsg := '���������������ʽ����';
//      ShowMsg(nMsg,sError);
//      Writelog(nMsg);
//      Exit;
//    end;

    if nwebOrderValue-FMaxQuantity>0.00001 then
    begin
      nMsg := '�̳ǻ���������������������������Ϊ[%f]��';
      nMsg := Format(nMsg,[FMaxQuantity]);
      ShowMsg(nMsg,sError);
      Writelog(nMsg);
      Exit;
    end;
    Result := True;
  end;
end;

function TfFormNewPurchaseCard.SaveBillProxy: Boolean;
var
  nHint:string;
  nWebOrderID:string;
  nList: TStrings;
  nOrderItem:stMallPurchaseItem;
  nOrder:string;
  nNewCardNo:string;
begin
  Result := False;
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := editWebOrderNo.Text;

  if EditID.Text='' then
  begin
    ShowMsg('δ��ѯ���ϻ���',sHint);
    Writelog('δ��ѯ���ϻ���');
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

  nList := TStringList.Create;
  try
    nList.Values['SQID'] := EditID.Text;
    nList.Values['Area'] := '';
    nList.Values['Truck'] := Trim(EditTruck.Text);
    nList.Values['Project'] := EditID.Text;
    nList.Values['CardType'] := 'L';

    nList.Values['ProviderID'] := nOrderItem.FProvID;
    nList.Values['ProviderName'] := nOrderItem.FProvName;
    nList.Values['StockNO'] := nOrderItem.FGoodsID;
    nList.Values['StockName'] := nOrderItem.FGoodsname;
    nList.Values['Value'] := EditValue.Text;

    nOrder := SaveOrder(PackerEncodeStr(nList.Text));
    if nOrder='' then
    begin
      nHint := '����ɹ���ʧ��';
      ShowMsg(nHint,sError);
      Writelog(nHint);
      Exit;
    end;
    SaveWebOrderMatch(nOrder,nWebOrderID);
  finally
    nList.Free;
  end;

  ShowMsg('�ɹ�������ɹ�', sHint);
  //����
  if not FSzttceApi.IssueOneCard(nNewCardNo) then
  begin
    nHint := '����ʧ��,�뵽��Ʊ���ڲ���ſ���[errorcode=%d,errormsg=%s]';
    nHint := Format(nHint,[FSzttceApi.ErrorCode,FSzttceApi.ErrorMsg]);
    Writelog(nHint);
    ShowMsg(nHint,sHint);
    Exit;
  end;

  nHint := '�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
  nHint := Format(nHint,[nNewCardNo]);
  ShowMsg(nHint,sHint);
  Writelog(nHint);

  if not SetBillCard(nOrder, EditTruck.Text,nNewCardNo, True) then
  begin
    nHint := '�ɹ��������ſ�ʧ�ܣ��뵽��Ʊ���ڴ���';
    ShowMsg(nHint,sHint);
    Writelog(nHint);
  end;
  Close;
end;

function TfFormNewPurchaseCard.SaveWebOrderMatch(const nBillID,
  nWebOrderID: string): Boolean;
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

function TfFormNewPurchaseCard.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    if not Result then
    begin
      nHint := '���ƺų���Ӧ����2λ';
      Writelog(nHint);
      Exit;
    end;
  end;

  if Sender = EditValue then
  begin
//    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    Result := IsNumber(EditValue.Text, True);
    if not Result then
    begin
      nHint := '����д��Ч�İ�����';
      Writelog(nHint);
      Exit;
    end;

    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, FMaxQuantity,rtLE);
    if not Result then
    begin
      nHint := '�ѳ����������';
      Writelog(nHint);
    end;
  end;
end;

end.
