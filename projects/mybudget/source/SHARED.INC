(*--------------------------------------------------------*)
(*   SHARED.INC                                           *)
(*                                                        *)
(*   Copyright (C) 2026 James Dooley <james@dooley.ch>    *)
(*                                                        *)
(*   History                                              *)
(*   07/03/2026 - Initial Version                         *)
(*--------------------------------------------------------*)

const
	BT_ERROR_CLS_NONE							: Byte =   0;
  BT_ERROR_CLS_USER							: Byte =   1;
  BT_ERROR_CLS_LOCK							: Byte =   2;
  BT_ERROR_CLS_NO_OP						: Byte =   3;
  BT_ERROR_CLS_HARD							: Byte = 	 4;

	NO_ERROR											: Byte =   0;
  INTERNAL_ERROR								: Byte = 255;
  DB_INTERNAL_ERROR							: Byte = 250;

	DUPLICATE_RECORD  						: Byte =   5;
  RECORD_NOT_FOUND              : Byte =  10;
  FOREIGN_KEY_NOT_FOUND					: Byte =  15;
  RECORD_DELETED								: Byte =  20;
  INVALID_RECORD								: Byte =  25;


  DBE_INIT_FAILED 							: Byte =  10;
  DBE_NO_CREATE_TABLE						:	Byte =  15;
	DBE_NO_OPEN_TABLE             : Byte =  20;
  DBE_INVALID_VERSION						: Byte =  25;

  CRUD_NO_ADD_REC								: Byte =  30;
  CRUD_NO_GET_REC								: Byte =  35;
  CRUD_REC_EXISTS								: Byte =  40;
  CRUD_NO_UPDATE								: Byte =  45;

  QRY_REC_NOT_FOUND							: Byte =  50;
  QRY_NO_FK_FOUND								: Byte =  55;

	ERR_FAILED_TO_CREATE_TABLE		: Byte = 	 10;
  ERR_FAILED_TO_OPEN_TABLE			: Byte = 	 15;
  ERR_FAILED_TO_INSERT_SEED_DATA: Byte = 	 20;
  ERR_FAILED_TO_ADD_RECORD			:	Byte = 	 25;
  ERR_FAILED_TO_ADD_KEY					:	Byte = 	 30;
  ERR_GEN_KEY_MISSING						:	Byte = 	 35;
  ERR_FAILED_TO_ADD_REC         :	Byte = 	 40;
  ERR_FAILED_TO_LOAD_REC        :	Byte = 	 45;
  ERR_FAILED_TO_UPDATE_REC      :	Byte = 	 50;
  ERR_FAILED_TO_DELETE_REC      :	Byte = 	 60;
  ERR_CONFIG_FILE_NOT_FOUND     : Byte = 	 70;
  ERR_FAILED_TO_LOAD_RECORD 		: Byte = 	 75;
  CRUD_RECORD_NOT_FOUND         : Byte = 	 80;
  CRUD_RECORD_KEY_NOT_DELETED   : Byte = 	 85;
  CRUD_RECORD_NOT_DELETED       : Byte = 	 90;
  CRUD_RECORD_EXISTS						: Byte = 	 95;
  CRUD_RECORD_NOT_ADDED					: Byte = 	100;
  CRUD_RECORD_FAILED_UPDATE			: Byte = 	105;



