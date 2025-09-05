//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#Include "totvs.ch"
//#Include "fwmvc.ch"
#Include "topconn.ch"

//Variáveis Estáticas
Static cTitulo := "Manutenção de BCDs (Mod.X)"

/*/{Protheus.doc} XBCD
Função de exemplo de Modelo X (Pai, Filho e Neto), com as tabelas de Artistas, CDs e Músicas
@author Neudo Campos Junior
@since 06/-3/2017
@version 1.0
@return Nil, Função não tem retorno
@example
u_XBCD()
/*/
User Function XBCD()
	Local aArea   := GetArea()
	Local oBrowse
	Private aRotina := MenuDef()

	//MsgInfo("Teste")

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de BCD
	oBrowse:SetAlias("ZB1")
	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil
/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Criação do menu MVC                                          |
*---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aArea   := GetArea()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.XBCD' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.XBCD' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.XBCD' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.XBCD' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

	RestArea(aArea)

Return aRot
/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Criação do modelo de dados MVC                               |
*---------------------------------------------------------------------*/
Static Function ModelDef()
	Local aArea   := GetArea()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZB1')
	Local oStFilho 		:= FWFormStruct(1, 'ZB2')
	Local oStNeto 		:= FWFormStruct(1, 'ZB3')
	Local aZB2Rel		:= {}
	Local aZB3Rel		:= {}
	Local aAuxTr 		:= CreateTrig()
	Local aAuxTr1 		:= CriaTrig()
	Local aAuxTr2 		:= CriaTrig2()
	Local aAuxTr3 		:= CriaTrig3()
	Local aAuxTr4 		:= CriaTrig4()
	Local aAuxTr5 		:= CriaTrig5()
	
	Local bVldPos := {|| zM1bPosS()} //Validação ao clicar no Confirmar
	Local bComp023 := { |oModelGrid, nLine, cAction, cField| COMP021LPRE(oModelGrid, nLine, cAction, cField) } //Validação para não deletar a linha

	//Definições dos campos
	oStPai:SetProperty("ZB1_EMP",   	MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "ExistCpo('ZB8',M->ZB1_EMP)"))      //Validação de Campo
	oStPai:SetProperty("ZB1_COD",		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))								//Modo de Edição
	oStPai:SetProperty("ZB1_COD",		MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "GetSXENum('ZB1','ZB1_COD')"))		//Ini Padrão
	oStPai:SetProperty("ZB1_PREFIX",   	MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "ExistCpo('ZB7',M->ZB1_PREFIX)"))      //Validação de Campo
	oStPai:SetProperty("ZB1_NUMLIN",   	MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "ExistCpo('ZB6',M->ZB1_NUMLIN)"))      //Validação de Campo
	oStPai:SetProperty("ZB1_ODOFIN",	MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "u_fValidBCD(1)"))						//Validação de Campo
	oStPai:SetProperty("ZB1_DATA",		MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "u_fValidBCD(4)"))						//Validação de Campo

	//oStFilho:SetProperty("ZB2_EMP",		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    	".F."))				//Modo de Edição
	//oStFilho:SetProperty("ZB2_EMP",		MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  	"M->ZB1_EMP"))		//Ini Padrão
	oStFilho:SetProperty("ZB2_COD",		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))				//Modo de Edição
	oStFilho:SetProperty("ZB2_COD",		MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "M->ZB1_COD"))		//Ini Padrão
	oStFilho:SetProperty("ZB2_TURNO",	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".T."))				//Modo de Edição
	oStFilho:SetProperty("ZB2_TURNO", 	MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "u_fNumAuto()"))                         //Ini Padrão
	oStFilho:SetProperty("ZB2_CATFIN",	MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "u_fValidBCD(3)"))						//Validação de Campo
	//oStFilho:SetProperty("ZB2_DATA",	MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "M->ZB1_DATA"))		//Ini Padrão
	//oStFilho:SetProperty("ZB2_NUMLIN",	MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "M->ZB1_NUMLIN"))		//Ini Padrão

	//oStNeto:SetProperty("ZB3_EMP",		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))                                 //Modo de Edição
	//oStNeto:SetProperty("ZB3_EMP",		MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "M->ZB1_EMP"))       					//Ini Padrão
	oStNeto:SetProperty("ZB3_COD",		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))                                 //Modo de Edição
	oStNeto:SetProperty("ZB3_COD",		MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "M->ZB1_COD"))       					//Ini Padrão
//	oStNeto:SetProperty("ZB3_TURNO",	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".T."))                                 //Modo de Edição
//	oStNeto:SetProperty("ZB3_TURNO",	MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "u_fValidBCD(2)"))       					//Ini Padrão
	oStNeto:SetProperty("ZB3_SENHA",   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "ExistCpo('ZB4',M->ZB3_SENHA)"))      //Validação de Campo
	oStNeto:SetProperty("ZB3_NIVEL",   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   "ExistCpo('ZB5',M->ZB3_NIVEL,2)"))      //Validação de Campo
	//Nao exige obrigatoriedade de pelo menos uma linha na grid neta
	//oStNeto:GetModel( "ZB3DETAIL" ):SetOptional( .T. )

	//	Gatilhos
	oStPai:AddTrigger(aAuxTr4[1],aAuxTr4[2],aAuxTr4[3],aAuxTr4[4])
	//oStPai:AddTrigger(aAuxTr5[1],aAuxTr5[2],aAuxTr5[3],aAuxTr5[4])
	oStFilho:AddTrigger(aAuxTr[1],aAuxTr[2],aAuxTr[3],aAuxTr[4])
	oStFilho:AddTrigger(aAuxTr1[1],aAuxTr1[2],aAuxTr1[3],aAuxTr1[4])
	oStNeto:AddTrigger(aAuxTr2[1],aAuxTr2[2],aAuxTr2[3],aAuxTr2[4])
	oStFilho:AddTrigger(aAuxTr3[1],aAuxTr3[2],aAuxTr3[3],aAuxTr3[4])

	

	//Criando o modelo e os relacionamentos
//	oModel := MPFormModel():New('XBCDM')
	oModel := MPFormModel():New('XBCDM', /*bVldPre*/, bVldPos, /*bVldCom*/, /*bVldCan*/)

	oModel:AddFields('ZB1MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZB2DETAIL','ZB1MASTER',oStFilho,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
//	oModel:AddGrid('ZB2DETAIL','ZB1MASTER',oStFilho,{|| fValidDel()}/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	oModel:AddGrid('ZB3DETAIL','ZB2DETAIL',oStNeto,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	//Fazendo o relacionamento entre o Pai e Filho
	//aAdd(aZB2Rel, {'ZB2_FILIAL',	'ZB1_FILIAL'} )
	aAdd(aZB2Rel, {'ZB2_FILIAL',	'xFilial( "ZB2" )'} )
	aAdd(aZB2Rel, {'ZB2_COD',		'ZB1_COD'})
	//aAdd(aZB2Rel, {'ZB2_EMP',		'ZB1_EMP'})

	//Fazendo o relacionamento entre o Filho e Neto
	//	aAdd(aZB3Rel, {'ZB3_FILIAL',	'ZB2_FILIAL'} )
	aAdd(aZB3Rel, {'ZB3_FILIAL',	'xFilial( "ZB3" )'} )
	aAdd(aZB3Rel, {'ZB3_COD',		'ZB2_COD'})
	//aAdd(aZB3Rel, {'ZB3_TURNO',		'ZB2_TURNO'})
	//aAdd(aZB3Rel, {'ZB3_EMP',		'ZB2_EMP'})

	oModel:SetRelation('ZB2DETAIL', aZB2Rel, ZB2->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('ZB2DETAIL'):SetUniqueLine({"ZB2_TURNO"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	oModel:SetRelation('ZB3DETAIL', aZB3Rel, ZB3->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('ZB3DETAIL'):SetUniqueLine({'ZB3_SENHA','ZB3_NIVEL'})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	//Setando as descrições
	oModel:SetDescription("Manutenção de BCDs - Mod. X")
	oModel:GetModel('ZB1MASTER'):SetDescription('BCDs')
	oModel:GetModel('ZB2DETAIL'):SetDescription('Turnos')
	oModel:GetModel('ZB3DETAIL'):SetDescription('Senhas')

	oModel:GetModel( 'ZB3DETAIL' ):SetNoDeleteLine(.T.)
	oModel:GetModel( 'ZB2DETAIL' ):SetNoDeleteLine(.T.)

	//Adicionando totalizadores
	//oModel:AddCalc('TOTAIS', 'ZZ1MASTER', 'ZZ2DETAIL', 'ZZ2_PRECO',  'XX_VALOR', 'SUM',   , , "Valor Total:" )
	//oModel:AddCalc('TOTAIS', 'ZZ2DETAIL', 'ZZ3DETAIL', 'ZZ3_CODMUS', 'XX_TOTAL', 'COUNT', , , "Total Musicas:" )

	RestArea(aArea)
Return oModel
/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Criação da visão MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Static Function ViewDef()
	Local oView			:= Nil
	Local oModel		:= FWLoadModel('XBCD')
	Local oStPai		:= FWFormStruct(2, 'ZB1')
	Local oStFilho		:= FWFormStruct(2, 'ZB2')
	Local oStNeto		:= FWFormStruct(2, 'ZB3')
	Local aArea   := GetArea()
	//	Local oStTot		:= FWCalcStruct(oModel:GetModel('TOTAIS'))

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZB1', oStPai,   'ZB1MASTER')
	oView:AddGrid('VIEW_ZB2',  oStFilho, 'ZB2DETAIL')
	oView:AddGrid('VIEW_ZB3',  oStNeto,  'ZB3DETAIL')
	//oView:AddField('VIEW_TOT', oStTot,   'TOTAIS')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 24)
	oView:CreateHorizontalBox('GRID',  30)
	oView:CreateHorizontalBox('GRID2', 40)
	//oView:CreateHorizontalBox('TOTAL', 13)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZB1', 'CABEC')
	oView:SetOwnerView('VIEW_ZB2', 'GRID')
	oView:SetOwnerView('VIEW_ZB3', 'GRID2')
	//oView:SetOwnerView('VIEW_TOT', 'TOTAL')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZB1','BCDs')
	oView:EnableTitleView('VIEW_ZB2','Turnos')
	oView:EnableTitleView('VIEW_ZB3','Senhas')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Código do Artista e CD
	//oStFilho:RemoveField('ZZ3_CODART')
	//oStFilho:RemoveField('ZZ3_CODCD')

	//Removendo campos
	//oStPai:RemoveField('ZB1_COD')
	oStPai:RemoveField('ZB1_BRAP')

	oStFilho:RemoveField('ZB2_COD')
//	oStFilho:RemoveField('ZB2_CODBCD')
//	oStFilho:RemoveField('ZB2_EMP')
//	oStFilho:RemoveField('ZB2_DATA')
//	oStFilho:RemoveField('ZB2_NUMLIN')

	oStNeto:RemoveField('ZB3_COD')
//	oStNeto:RemoveField('ZB3_EMP')
//	oStNeto:RemoveField('ZB3_CODBCD')
//	oStNeto:RemoveField('ZB3_TURNO')

	//	oStNeto:RemoveField('ZZ3_CODCD')
	RestArea(aArea)
Return oView

/*---------------------------------------------------------------------*
| Func:  fValidBCD                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar para validação de informa                    |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
User Function fValidBCD(nOpc)
	Local xRetR
	Local xRetR2
	Local oModelGrid
	Local oModelPad
	Local nLinAtu
	Local aArea   := GetArea()

	Do Case
		Case nOpc == 1
		IF M->ZB1_ODOINI > M->ZB1_ODOFIN
			Help( ,, 'Help',, 'Odometro final não pode ser menor do que o inicial!', 1, 0 )
			Return .F.
		ELSE
			Return .T.
		ENDIF

		Case nOpc == 2
		oModelPad	:= FWModelActive()
		oModelGrid	:= oModelPad:GetModel('ZB2DETAIL')
		nLinAtu    	:= oModelGrid:nLine

		//nPosUM := aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_UM" }) - retorna a posição do elemento (lin/col) da grid (array)
		//onde o conteúda do aHeader = "D1_UM"

		xRetR		:= ""
		//xRetR		:= oModelGrid:aCols[nLinAtu][aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("ZB2_TURNO")})]
		Return xRetR

		Case nOpc == 3
		oModelPad	:= FWModelActive()
		oModelGrid	:= oModelPad:GetModel('ZB2DETAIL')
		nLinAtu    	:= oModelGrid:nLine
		xRetR		:= oModelGrid:aCols[nLinAtu][aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("ZB2_CATINI")})]
		xRetR2		:= oModelGrid:aCols[nLinAtu][aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("ZB2_CATFIN")})]

		IF xRetR > xRetR2
			Return .F.
			Help( ,, 'Help',, 'Catraca final não pode ser menor do que a inicial!', 1, 0 )
		ELSE
			Return .T.
		ENDIF

	EndCase

	RestArea(aArea)

Return

/*---------------------------------------------------------------------*
| Func:  fNumAuto                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar para numeração automatica                    |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

User Function fNumAuto()
	Local aArea 		:= GetArea()
	Local cCod  		:= Val(StrTran(Space(TamSX3('ZB2_TURNO')[1]), ' ', '0'))
	Local oModelPad  	:= FWModelActive()
	Local oModelGrid 	:= oModelPad:GetModel('ZB2DETAIL')
	Local nOperacao  	:= oModelPad:nOperation
	Local nLinAtu    	:= oModelGrid:nLine
	Local nPosCod    	:= aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("ZB2_TURNO")})

	//Se for a primeira linha
	If nLinAtu < 1
		cCod += 10
		//Senão, pega o valor da última linha
	Else
		cCod := oModelGrid:aCols[nLinAtu][nPosCod]
		cCod	:= cValToChar(Val(cCod) + 10)
	EndIf

	cCod	:=	cValToChar(cCod)

	RestArea(aArea)

Return cCod
/*---------------------------------------------------------------------*
| Func:  CreateTrigger                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar na Criação de Gatillhos                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function CreateTrigger()
	Local aAux :=   FwStruTrigger(;
	"ZB2_HRFIN" ,; 														// Campo Dominio
	"ZB2_QTDHRS" ,; 														// Campo de Contradominio
	"SUBSTR(ElapTime(M->ZB2_HRINIC+':00',M->ZB2_HRFIN+':00'),1,5)",;	 	// Regra de Preenchimento
	.F. ,;																// Se posicionara ou nao antes da execucao do gatilhos
	"" ,; 																// Alias da tabela a ser posicionada
	0 ,;  																// Ordem da tabela a ser posicionada
	"" ,;  										// Chave de busca da tabela a ser posicionada
	NIL ,;  										// Condicao para execucao do gatilho
	"01" )  										// Sequencia do gatilho (usado para identificacao no caso de erro)
Return aAux

/*---------------------------------------------------------------------*
| Func:  CriaTrig                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar na Criação de Gatillhos                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function CriaTrig()
	Local aAux :=   FwStruTrigger(;
	"ZB2_RENDA" ,; 														// Campo Dominio
	"ZB2_DIFERE" ,; 														// Campo de Contradominio
	"U_fTrigDif()	",;			 			// Regra de Preenchimento
	.F. ,;																// Se posicionara ou nao antes da execucao do gatilhos
	"" ,; 																// Alias da tabela a ser posicionada
	0 ,;  																// Ordem da tabela a ser posicionada
	"" ,;  										// Chave de busca da tabela a ser posicionada
	NIL ,;  										// Condicao para execucao do gatilho
	"01" )  										// Sequencia do gatilho (usado para identificacao no caso de erro)

Return aAux
//StrTran(TransForm(SubHoras(M->ZB2_HRFIN,M->ZB2_HRINIC),'@E 999.99'),',',':')

/*---------------------------------------------------------------------*
| Func:  CriaTrig2                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar na Criação de Gatillhos                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function CriaTrig2()
	Local aAux :=   FwStruTrigger(;
	"ZB3_QNTD" ,; 							// Campo Dominio
	"ZB3_TOTAL" ,; 							// Campo de Contradominio
	"(M->ZB3_QNTD)*(M->ZB3_VLRPAS)",;			 	// Regra de Preenchimento
	.F. ,;									// Se posicionara ou nao antes da execucao do gatilhos
	"" ,; 									// Alias da tabela a ser posicionada
	0 ,;  									// Ordem da tabela a ser posicionada
	"" ,;  									// Chave de busca da tabela a ser posicionada
	NIL ,;  									// Condicao para execucao do gatilho
	"01" )  									// Sequencia do gatilho (usado para identificacao no caso de erro)
Return aAux

/*---------------------------------------------------------------------*
| Func:  CriaTrig3                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar na Criação de Gatillhos                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function CriaTrig3()
	Local aAux :=   FwStruTrigger(;
	"ZB2_CATFIN" ,; 							// Campo Dominio
	"ZB2_PASSAG" ,; 							// Campo de Contradominio
	"(M->ZB2_CATFIN)-(M->ZB2_CATINI)",;		// Regra de Preenchimento
	.F. ,;									// Se posicionara ou nao antes da execucao do gatilhos
	"" ,; 									// Alias da tabela a ser posicionada
	0 ,;  									// Ordem da tabela a ser posicionada
	"" ,;  									// Chave de busca da tabela a ser posicionada
	NIL ,;  									// Condicao para execucao do gatilho
	"01" )  									// Sequencia do gatilho (usado para identificacao no caso de erro)
Return aAux

/*---------------------------------------------------------------------*
| Func:  CriaTrig4                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar na Criação de Gatillhos                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function CriaTrig4()
	Local aAux :=   FwStruTrigger(;
	"ZB1_NUMLIN" ,; 							// Campo Dominio
	"ZB1_DESCLI" ,; 							// Campo de Contradominio
	"posicione('ZB6',1,xFilial('ZB6')+M->ZB1_NUMLIN,'ZB6_DESC')",;	// Regra de Preenchimento
	.F. ,;									// Se posicionara ou nao antes da execucao do gatilhos
	"" ,; 									// Alias da tabela a ser posicionada
	0 ,;  									// Ordem da tabela a ser posicionada
	"" ,;  									// Chave de busca da tabela a ser posicionada
	NIL ,;  									// Condicao para execucao do gatilho
	"01" )  									// Sequencia do gatilho (usado para identificacao no caso de erro)
Return aAux

/*---------------------------------------------------------------------*
| Func:  CriaTrig5                                                      |
| Autor: Daniel Atilio                                                |
| Data:  03/09/2016                                                   |
| Desc:  Funcao auxiliar na Criação de Gatillhos                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function CriaTrig5()
	Local aAux :=   FwStruTrigger(;
	"ZB1_NUMLIN" ,; 							// Campo Dominio
	"ZB1_VLRPAS" ,; 							// Campo de Contradominio
	"posicione('ZB6',1,xFilial('ZB6')+M->ZB1_NUMLIN,'ZB6_VLRPAS')",;	// Regra de Preenchimento
	.F. ,;									// Se posicionara ou nao antes da execucao do gatilhos
	"" ,; 									// Alias da tabela a ser posicionada
	0 ,;  									// Ordem da tabela a ser posicionada
	"" ,;  									// Chave de busca da tabela a ser posicionada
	NIL ,;  									// Condicao para execucao do gatilho
	"01" )  									// Sequencia do gatilho (usado para identificacao no caso de erro)
Return aAux

//StrTran(TransForm(SubHoras(M->ZB2_HRFIN,M->ZB2_HRINIC),'@E 999.99'),',',':')

/*/{Protheus.doc} zM1bPos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@type function
@author Atilio
@since 03/09/2016
@version 1.0
/*/
/*---------------------------------------------------------------------*
| Func:  zM1bPosS (Validação Pós-Confirmação)                          |
| Autor:  Atualizado por ChatGPT (OpenAI)                             |
| Desc:  Valida e trata dados antes de gravar alteração no banco      |
*---------------------------------------------------------------------*/
Static Function zM1bPosS()
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oZB1      := oModel:GetModel('ZB1MASTER')
	Local oZB2      := oModel:GetModel('ZB2DETAIL')
	Local oZB3      := oModel:GetModel('ZB3DETAIL')
	Local nOp       := oModel:GetOperation()
	Local cNumLin   := oZB1:GetValue('ZB1_NUMLIN')
	Local cEmp1     := oZB1:GetValue('ZB1_EMP')
	Local dData     := oZB1:GetValue('ZB1_DATA')
	Local lOk       := .T.
	Local nI        := 0

	// ======== Validação específica para Alteração ========
	If nOp == MODEL_OPERATION_UPDATE

		// Exige pelo menos um turno na grid filha (ZB2)
		If oZB2:Length() <= 0
			Help(,, "Aviso",, "É necessário cadastrar ao menos um TURNO.", 1, 0)
			RestArea(aArea)
			Return .F.
		EndIf

		// Atualiza dados dos filhos (ZB2) com base nos dados do pai
		For nI := 1 To oZB2:Length()
			If Len(oZB2:aCols) >= nI .And. Len(oZB2:aCols[nI]) >= 23
//				oZB2:aCols[nI][21] := dData     // ZB2_DATA
//				oZB2:aCols[nI][22] := cNumLin   // ZB2_NUMLIN
//				oZB2:aCols[nI][3]  := cEmp1     // ZB2_EMP
			Else
				Help(,, "Erro",, "A linha "+cValToChar(nI)+" da grid ZB2 está mal formada ou incompleta.", 1, 0)
				RestArea(aArea)
				Return .F.
			EndIf
		Next

		// Atualiza EMP na grid neta (ZB3)
		For nI := 1 To oZB3:Length()
			If Len(oZB3:aCols) >= nI .And. Len(oZB3:aCols[nI]) >= 5
//				oZB3:aCols[nI][5] := cEmp1 // ZB3_EMP
			Else
				Help(,, "Erro",, "A linha "+cValToChar(nI)+" da grid ZB3 está mal formada ou incompleta.", 1, 0)
				RestArea(aArea)
				Return .F.
			EndIf
		Next

		/*
		// ======== Log de Auditoria (opcional) =========
		Local cUsuario := UsrRetName()
		Local cCodigo  := FWUser()
		Local cCodBCD  := oZB1:GetValue("ZB1_COD")
		FWLogMsg("Usuário " + cUsuario + " (" + cCodigo + ") alterou o BCD " + cCodBCD + ".")
		*/
	EndIf

	RestArea(aArea)
Return lOk



//Funcao para tratar o gatilho do campo ZB2_RENDA
User Function fTrigDif()
	Local xVarA  :=	ZB1_VLRPAS
	Local xVarB  :=	ACOLS[N][12]
	Local xVarC  :=	M->ZB2_RENDA

	Local xRetD  :=	(xVarA*xVarB)-xVarC

Return(xRetD)
