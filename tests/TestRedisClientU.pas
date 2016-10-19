unit TestRedisClientU;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, System.Variants, IdTCPClient, Winapi.Windows, Vcl.Dialogs,
  Vcl.Forms, IdTCPConnection, Vcl.Controls, System.Classes, System.SysUtils,
  IdComponent, Winapi.Messages, IdBaseComponent, Vcl.Graphics, Vcl.StdCtrls,
  Redis.Client, Redis.Commons, Redis.Values;

type
  // Test methods for class IRedisClient

  TestRedisClient = class(TTestCase)
  strict private
    FRedis: IRedisClient;
  private
    FArrRes: TArray<string>;
    FArrResNullable: TRedisArray;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCommandParser;
    procedure TestExecuteWithStringArrayResponse;
    procedure TestSetGet;
    procedure TestSetGetUnicode;
    procedure TestAPPEND;
    procedure TestKEYS;
    procedure TestSTRLEN;
    procedure TestGETRANGE;
    procedure TestSETRANGE;
    procedure TestMSET;
    procedure TestINCR_DECR;
    procedure TestEXPIRE;
    procedure TestDelete;
    procedure TestRPUSH_RPOP;
    procedure TestRPUSHX_LPUSHX;
    procedure TestLPUSH_LPOP;
    procedure TestLRANGE;
    procedure TestLLEN;
    procedure TestLTRIM;
    procedure TestZADD_ZRANK_ZCARD;
    procedure TestRPOPLPUSH;
    procedure TestBRPOPLPUSH;
    procedure TestBLPOP;
    procedure TestBRPOP;
    procedure TestLREM;
    procedure TestSELECT;
    procedure TestMULTI;
    procedure TestHSetHGet;
    procedure TestHMSetHMGet;
    procedure TestHMGetBUGWithEmptyValues;
    procedure TestAUTH;
    procedure TestRANDOMKEY;
    procedure TestMOVE;
    procedure TestHSetHGet_Bytes;
    procedure TestWATCH_MULTI_EXEC_OK;
    procedure TestWATCH_MULTI_EXEC_Fail;
    procedure TestWATCH_OK;
    procedure TestWATCH_Fail;
    // procedure TestSUBSCRIBE;
    procedure TestGET_NULLABLE;
    procedure TestHSetHGet_NULLABLE;
    procedure TestLPOP_RPOP_NULLABLE;
    procedure TestBRPOP_NULLABLE;
    procedure TestBLPOP_NULLABLE;
  end;

implementation

uses System.rtti, System.Generics.Collections,
  System.Generics.Defaults;

procedure TestRedisClient.SetUp;
begin
  FRedis := NewRedisClient('localhost', 6379, 'indy');
end;

procedure TestRedisClient.TearDown;
begin
  FRedis := nil;
end;

procedure TestRedisClient.TestAPPEND;
var
  lRes: TRedisString;
begin
  FRedis.DEL(['mykey']);
  CheckEquals(4, FRedis.APPEND('mykey', '1234'), 'Wrong length');
  CheckEquals(8, FRedis.APPEND('mykey', '5678'), 'Wrong length');
  lRes := FRedis.GET('mykey');
  CheckTrue(lRes.HasValue, 'Key doesn''t exist');
  CheckEquals('12345678', lRes, 'Wrong key value...');
end;

procedure TestRedisClient.TestAUTH;
begin
  // the TEST Redis instance is not protected with a password
  ExpectedException := ERedisException;
  FRedis.AUTH('foo');
end;

procedure TestRedisClient.TestBLPOP;
begin
{$WARN SYMBOL_DEPRECATED OFF}
  // setup list
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['one', 'two']);

  // pop from a non-empty list
  CheckTrue(FRedis.BLPOP(['mylist'], 1, FArrRes));
  CheckEquals('mylist', FArrRes[0]);
  CheckEquals('one', FArrRes[1]);

  // pop from a non-empty list
  CheckTrue(FRedis.BLPOP(['mylist'], 1, FArrRes));
  CheckEquals('mylist', FArrRes[0]);
  CheckEquals('two', FArrRes[1]);

  // pop from a empty list, check the timeout
  CheckFalse(FRedis.BLPOP(['mylist'], 1, FArrRes));
  CheckEquals(0, Length(FArrRes));

  // now, test if it works when another thread pushes a values into the list
  TThread.CreateAnonymousThread(
    procedure
    var
      Redis: IRedisClient;
    begin
      Redis := NewRedisClient('localhost');
      Redis.RPUSH('mylist', ['from', 'another', 'thread']);
    end).Start;

  CheckTrue(FRedis.BLPOP(['mylist'], 10, FArrRes));
  CheckEquals(2, Length(FArrRes));
end;

procedure TestRedisClient.TestBLPOP_NULLABLE;
var
  lArrRes: TRedisArray;
begin
  // setup list
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['one', 'two']);

  // pop from a non-empty list
  lArrRes := FRedis.BLPOP(['mylist'], 1);
  CheckEquals('mylist', lArrRes.Value[0]);
  CheckEquals('one', lArrRes.Value[1]);

  // pop from a non-empty list
  lArrRes := FRedis.BLPOP(['mylist'], 1);
  CheckEquals('mylist', lArrRes.Value[0]);
  CheckEquals('two', lArrRes.Value[1]);

  // pop from a empty list, check the timeout
  lArrRes := FRedis.BLPOP(['mylist'], 1);
  CheckTrue(lArrRes.IsNull);

  // now, test if it works when another thread pushes a values into the list
  TThread.CreateAnonymousThread(
    procedure
    var
      Redis: IRedisClient;
    begin
      Redis := TRedisClient.Create;
      Redis.Connect;
      Redis.LPUSH('mylist', ['from', 'another', 'thread']);
    end).Start;

  lArrRes := FRedis.BLPOP(['mylist'], 10);
  CheckFalse(lArrRes.IsNull);
  CheckEquals('mylist', lArrRes.Value[0]);
  CheckEquals('thread', lArrRes.Value[1]);
end;

procedure TestRedisClient.TestBRPOP_NULLABLE;
var
  lArrRes: TRedisArray;
begin
  // setup list
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['one', 'two']);

  // pop from a non-empty list
  lArrRes := FRedis.BRPOP(['mylist'], 1);
  CheckEquals('mylist', lArrRes.Value[0]);
  CheckEquals('two', lArrRes.Value[1]);

  // pop from a non-empty list
  lArrRes := FRedis.BRPOP(['mylist'], 1);
  CheckEquals('mylist', lArrRes.Value[0]);
  CheckEquals('one', lArrRes.Value[1]);

  // pop from a empty list, check the timeout
  lArrRes := FRedis.BRPOP(['mylist'], 1);
  CheckTrue(lArrRes.IsNull);

  // now, test if it works when another thread pushes a values into the list
  TThread.CreateAnonymousThread(
    procedure
    var
      Redis: IRedisClient;
    begin
      Redis := TRedisClient.Create;
      Redis.Connect;
      Redis.RPUSH('mylist', ['from', 'another', 'thread']);
    end).Start;

  lArrRes := FRedis.BRPOP(['mylist'], 10);
  CheckFalse(lArrRes.IsNull);
  CheckEquals('mylist', lArrRes.Value[0]);
  CheckEquals('thread', lArrRes.Value[1]);
end;

procedure TestRedisClient.TestBRPOP;
begin
  // setup list
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['one', 'two']);

  // pop from a non-empty list
  CheckTrue(FRedis.BRPOP(['mylist'], 1, FArrRes));
  CheckEquals('mylist', FArrRes[0]);
  CheckEquals('two', FArrRes[1]);

  // pop from a non-empty list
  CheckTrue(FRedis.BRPOP(['mylist'], 1, FArrRes));
  CheckEquals('mylist', FArrRes[0]);
  CheckEquals('one', FArrRes[1]);

  // pop from a empty list, check the timeout
  CheckFalse(FRedis.BRPOP(['mylist'], 1, FArrRes));
  CheckEquals(0, Length(FArrRes));

  // now, test if it works when another thread pushes a values into the list
  TThread.CreateAnonymousThread(
    procedure
    var
      Redis: IRedisClient;
    begin
      Redis := NewRedisClient('localhost');
      Redis.RPUSH('mylist', ['from', 'another', 'thread']);
    end).Start;

  CheckTrue(FRedis.BRPOP(['mylist'], 10, FArrRes));
  CheckEquals(2, Length(FArrRes));
end;

procedure TestRedisClient.TestBRPOPLPUSH;
var
  Value: string;
begin
  FRedis.DEL(['mylist', 'myotherlist']);
  CheckFalse(FRedis.BRPOPLPUSH('mylist', 'myotherlist', Value, 1));
  CheckEquals('', Value);
  FRedis.RPUSH('mylist', ['one', 'two']);

  CheckTrue(FRedis.BRPOPLPUSH('mylist', 'myotherlist', Value, 1));
  CheckEquals('two', Value);
  CheckTrue(FRedis.RPOP('myotherlist', Value));
  CheckEquals('two', Value);

  CheckTrue(FRedis.BRPOPLPUSH('mylist', 'myotherlist', Value, 1));
  CheckEquals('one', Value);
  CheckTrue(FRedis.RPOP('myotherlist', Value));
  CheckEquals('one', Value);

  CheckFalse(FRedis.BRPOPLPUSH('mylist', 'myotherlist', Value, 1));
  CheckEquals('', Value);
end;

procedure TestRedisClient.TestCommandParser;
  procedure CheckSimpleSet;
  begin
    CheckEquals('set', FArrRes[0]);
    CheckEquals('nome', FArrRes[1]);
    CheckEquals('daniele', FArrRes[2]);
  end;

  procedure CheckSimpleSet2;
  begin
    CheckEquals('set', FArrRes[0]);
    CheckEquals('no me', FArrRes[1]);
    CheckEquals('da ni\ele', FArrRes[2]);
  end;

begin
  FArrRes := FRedis.Tokenize('set nome daniele');
  CheckSimpleSet;
  FArrRes := FRedis.Tokenize('set    nome  daniele');
  CheckSimpleSet;
  FArrRes := FRedis.Tokenize('   set    "nome"    daniele   ');
  CheckSimpleSet;
  FArrRes := FRedis.Tokenize('   set    "nome"    "daniele"   ');
  CheckSimpleSet;
  FArrRes := FRedis.Tokenize('set  nome "daniele"');
  CheckSimpleSet;
  FArrRes := FRedis.Tokenize('set  "no me" "da ni\ele"');
  CheckSimpleSet2;
  ExpectedException := ERedisException;
  FArrRes := FRedis.Tokenize('set nome "daniele');
end;

procedure TestRedisClient.TestDelete;
begin
  FRedis.&SET('NOME', 'Daniele');
  FRedis.&SET('COGNOME', 'Teti');
  CheckEquals(1, FRedis.DEL(['NOME']));
  CheckFalse(FRedis.GET('NOME').HasValue);
  CheckTrue(FRedis.GET('COGNOME').HasValue);
end;

procedure TestRedisClient.TestExecuteWithStringArrayResponse;
var
  lCmd: IRedisCommand;
begin
  FRedis.FLUSHDB;
  lCmd := NewRedisCommand('keys');
  lCmd.Add('*o*');
  CheckTrue(FRedis.ExecuteAndGetArray(lCmd).IsNull);
  FRedis.&SET('1one', '1');
  FRedis.&SET('2one', '2');
  CheckEquals(2, Length(FRedis.ExecuteAndGetArray(lCmd).Value));
end;

procedure TestRedisClient.TestEXPIRE;
var
  lRes: TRedisString;
begin
  FRedis.&SET('daniele', '1234');
  FRedis.EXPIRE('daniele', 1);
  lRes := FRedis.GET('daniele');
  CheckEquals('1234', lRes);
  TThread.Sleep(1100);
  CheckFalse(FRedis.GET('daniele').HasValue);
end;

procedure TestRedisClient.TestGETRANGE;
begin
  FRedis.DEL(['mykey']);
  CheckEquals('', FRedis.GETRANGE('mykey', 0, 1));
  FRedis.&SET('mykey', '0123456789');
  CheckEquals('0', FRedis.GETRANGE('mykey', 0, 0));
  CheckEquals('01', FRedis.GETRANGE('mykey', 0, 1));
  CheckEquals('12', FRedis.GETRANGE('mykey', 1, 2));
  CheckEquals('0123456789', FRedis.GETRANGE('mykey', 0, -1));
  CheckEquals('456789', FRedis.GETRANGE('mykey', 4, -1));
  CheckEquals('45678', FRedis.GETRANGE('mykey', 4, -2));
  CheckEquals('', FRedis.GETRANGE('mykey', 4, 2));
end;

procedure TestRedisClient.TestGET_NULLABLE;
var
  lResp: TRedisString;
begin
  FRedis.DEL(['mykey']);
  lResp := FRedis.GET('mykey');
  CheckFalse(lResp.HasValue);
  FRedis.&SET('mykey', 'abc');
  lResp := FRedis.GET('mykey');
  CheckTrue(lResp.HasValue);
  CheckEquals('abc', lResp);
end;

procedure TestRedisClient.TestHMGetBUGWithEmptyValues;
var
  Values: TRedisArray;
begin
  FRedis.HSET('abc', 'Name', 'Daniele Teti');
  FRedis.HSET('abc', 'Address', '');
  FRedis.HSET('abc', 'Postcode', '12345');
  // there was an access violation here
  Values := FRedis.HMGET('abc', ['Name', 'Address', 'Postcode', 'notvalid', 'Postcode']);
  CheckTrue(Values.HasValue);
  CheckTrue(Values.Value[0].HasValue);
  CheckEquals('Daniele Teti', Values.Value[0]);
  CheckTrue(Values.Value[1].HasValue);
  CheckEquals('', Values.Value[1]);
  CheckTrue(Values.Value[2].HasValue);
  CheckEquals('12345', Values.Value[2]);
  CheckTrue(Values.Value[3].IsNull);
  CheckFalse(Values.Value[3].HasValue);
  CheckTrue(Values.Value[4].HasValue);
  CheckEquals('12345', Values.Value[4]);
end;

procedure TestRedisClient.TestHMSetHMGet;
const
  C_KEY = 'thekey';
var
  lValues: TRedisArray;
begin
  FRedis.DEL([C_KEY]);
  FRedis.HMSET(C_KEY, ['field1', 'field2', 'field3'],
    ['value1', 'value2', 'value3']);
  lValues := FRedis.HMGET(C_KEY, ['field1', 'field2', 'field3']);

  CheckEqualsString('value1', lValues.Value[0]);
  CheckEqualsString('value2', lValues.Value[1]);
  CheckEqualsString('value3', lValues.Value[2]);
end;

procedure TestRedisClient.TestHSetHGet;
var
  aResult: string;
begin
  FRedis.DEL(['mykey']);
  FRedis.HSET('mykey', 'first_name', 'Daniele');
  FRedis.HSET('mykey', 'last_name', 'Teti');
  FRedis.HGET('mykey', 'first_name', aResult);
  CheckEqualsString('Daniele', aResult);
  FRedis.HGET('mykey', 'last_name', aResult);
  CheckEqualsString('Teti', aResult);
end;

procedure TestRedisClient.TestHSetHGet_Bytes;
const
  C_KEY = 'mykey';
  C_field = 'name';
  C_VALUE = 'Daniele';
var
  aResult: Tbytes;
begin
  FRedis.DEL([C_KEY]);
  FRedis.HSET(C_KEY, C_field, C_VALUE);
  FRedis.HGET(C_KEY, C_field, aResult);
  CheckEqualsString(C_VALUE, StringOf(aResult));
end;

procedure TestRedisClient.TestHSetHGet_NULLABLE;
var
  lResult: TRedisString;
begin
  FRedis.DEL(['mykey']);
  FRedis.HSET('mykey', 'first_name', 'Daniele');
  FRedis.HSET('mykey', 'last_name', 'Teti');
  lResult := FRedis.HGET('mykey', 'first_name');
  CheckEqualsString('Daniele', lResult);
  lResult := FRedis.HGET('mykey', 'last_name');
  CheckEqualsString('Teti', lResult);
  lResult := FRedis.HGET('mykey', 'notexist');
  CheckFalse(lResult.HasValue);
end;

procedure TestRedisClient.TestINCR_DECR;
begin
  FRedis.&SET('daniele', '-1');
  CheckEquals(0, FRedis.INCR('daniele'));
  FRedis.&SET('daniele', '1');
  CheckEquals(2, FRedis.INCR('daniele'));
  CheckEquals(1, FRedis.DECR('daniele'));
  FRedis.DEL(['daniele']);
  CheckEquals(-1, FRedis.DECR('daniele'));
end;

procedure TestRedisClient.TestKEYS;
var
  lRes: TRedisArray;
  lArr: TArray<TRedisString>;
begin
  FRedis.&SET('daniele1', 'value1');
  FRedis.&SET('daniele2', 'value1');
  FRedis.&SET('daniele3', 'value1');
  FRedis.&SET('daniele4', 'value1');
  lRes := FRedis.KEYS('d*');
  lArr := lRes.Value;
  TArray.Sort<TRedisString>(lArr, TComparer<TRedisString>.Construct(
    function(const Left, Right: TRedisString): Integer
    begin
      Result := TComparer<string>.Default.Compare(Left, Right);
    end));
  CheckEquals('daniele1', lArr[0]);
  CheckEquals('daniele2', lArr[1]);
  CheckEquals('daniele3', lArr[2]);
  CheckEquals('daniele4', lArr[3]);

  lRes := FRedis.KEYS('XX*');
  CheckTrue(lRes.IsNull);
end;

procedure TestRedisClient.TestLLEN;
begin
  FRedis.DEL(['mylist']);
  CheckEquals(0, FRedis.LLEN('mylist'));

  FRedis.RPUSH('mylist', ['one', 'two']);
  CheckEquals(2, FRedis.LLEN('mylist'));

  FRedis.&SET('myvalue', '3');
  ExpectedException := ERedisException;
  FRedis.LLEN('myvalue');
end;

procedure TestRedisClient.TestLPOP_RPOP_NULLABLE;
var
  lResp: TRedisString;
begin
  FRedis.DEL(['mylist']);
  FRedis.LPUSH('mylist', ['one', 'two', 'three']);
  lResp := FRedis.LPOP('mylist');
  CheckEquals('three', lResp);
  lResp := FRedis.RPOP('mylist');
  CheckEquals('one', lResp);
  lResp := FRedis.LPOP('mylist');
  CheckEquals('two', lResp);
  lResp := FRedis.LPOP('mylist');
  CheckFalse(lResp.HasValue);
  lResp := FRedis.RPOP('mylist');
  CheckFalse(lResp.HasValue);
end;

procedure TestRedisClient.TestLPUSH_LPOP;
var
  Value: string;
begin
  FRedis.DEL(['mylist']);
  FRedis.LPUSH('mylist', ['one', 'two', 'three']);

  CheckTrue(FRedis.LPOP('mylist', Value));
  CheckEquals('three', Value);

  CheckTrue(FRedis.LPOP('mylist', Value));
  CheckEquals('two', Value);

  CheckTrue(FRedis.LPOP('mylist', Value));
  CheckEquals('one', Value);

  CheckFalse(FRedis.LPOP('mylist', Value))
end;

procedure TestRedisClient.TestLRANGE;
begin
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['one', 'two', 'three', 'four', 'five']);
  FArrResNullable := FRedis.LRANGE('mylist', 0, 1);
  CheckEquals(2, Length(FArrResNullable.Value));
  CheckEquals('one', FArrResNullable.Value[0]);
  CheckEquals('two', FArrResNullable.Value[1]);

  FArrResNullable := FRedis.LRANGE('mylist', -1, -1);
  CheckEquals(1, Length(FArrResNullable.Value));
  CheckEquals('five', FArrResNullable.Value[0]);

  FArrResNullable := FRedis.LRANGE('mylist', 0, 20);
  CheckEquals(5, Length(FArrResNullable.Value));
  CheckEquals('one', FArrResNullable.Value[0]);
  CheckEquals('two', FArrResNullable.Value[1]);
  CheckEquals('three', FArrResNullable.Value[2]);
  CheckEquals('four', FArrResNullable.Value[3]);
  CheckEquals('five', FArrResNullable.Value[4]);

  FArrResNullable := FRedis.LRANGE('notexists', 0, 20);
  CheckTrue(FArrResNullable.IsNull);
end;

procedure TestRedisClient.TestLREM;
begin
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['hello', 'hello', 'foo', 'hello']);
  FRedis.LREM('mylist', -2, 'hello');
  FArrResNullable := FRedis.LRANGE('mylist', 0, -1);
  CheckEquals('hello', FArrResNullable.Value[0]);
  CheckEquals('foo', FArrResNullable.Value[1]);
end;

procedure TestRedisClient.TestLTRIM;
begin
  FRedis.DEL(['mylist']);
  CheckEquals(0, FRedis.LLEN('mylist'));

  FRedis.RPUSH('mylist', ['one', 'two', 'three', 'four', 'five']);
  CheckEquals(5, FRedis.LLEN('mylist'));

  FRedis.LTRIM('mylist', 0, 2);
  CheckEquals(3, FRedis.LLEN('mylist'));

  FRedis.LTRIM('mylist', 1, -2);
  CheckEquals(1, FRedis.LLEN('mylist'));

  FRedis.LTRIM('mylist', 10, -10);
  CheckEquals(0, FRedis.LLEN('mylist'));
end;

procedure TestRedisClient.TestMOVE;
var
  lRes: TRedisNullable<string>;
begin
  FRedis.SELECT(0);
  FRedis.FLUSHDB;
  FRedis.SELECT(1);
  FRedis.FLUSHDB;

  FRedis.SELECT(0);
  FRedis.&SET('mykey', '123');
  FRedis.MOVE('mykey', 1);
  lRes := FRedis.GET('mykey');
  CheckTrue(lRes.IsNull);
  FRedis.SELECT(1);
  lRes := FRedis.GET('mykey');
  CheckTrue(lRes.HasValue);
  CheckEquals('123', lRes);
end;

procedure TestRedisClient.TestMSET;
var
  lRes: TRedisArray;
begin
  FRedis.FLUSHDB;
  CheckTrue(FRedis.MSET(['one', '1', 'two', '2', 'three', '3']));
  lRes := FRedis.KEYS('*e*');
  CheckEquals(2, Length(lRes.Value));
end;

procedure TestRedisClient.TestMULTI;
begin
  FArrResNullable := FRedis.MULTI(
    procedure(const Redis: IRedisClient)
    begin
      Redis.&SET('name', 'Daniele');
      Redis.DEL(['name']);
    end);
  CheckEquals('OK', FArrResNullable.Value[0]);
  CheckEquals('1', FArrResNullable.Value[1]);
  CheckFalse(FRedis.GET('name').HasValue);
end;

procedure TestRedisClient.TestRANDOMKEY;
var
  lRes: TRedisNullable<string>;
begin
  FRedis.FLUSHDB;
  lRes := FRedis.RANDOMKEY;
  CheckTrue(lRes.IsNull);
  FRedis.&SET('mykey', 'myvalue');
  lRes := FRedis.RANDOMKEY;
  CheckFalse(lRes.IsNull);
  CheckEquals('mykey', lRes.Value);
end;

procedure TestRedisClient.TestRPOPLPUSH;
var
  Value: string;
begin
  FRedis.DEL(['mylist', 'myotherlist']);
  CheckFalse(FRedis.RPOPLPUSH('mylist', 'myotherlist', Value));
  CheckEquals('', Value);
  FRedis.RPUSH('mylist', ['one', 'two']);

  CheckTrue(FRedis.RPOPLPUSH('mylist', 'myotherlist', Value));
  CheckEquals('two', Value);
  CheckTrue(FRedis.RPOP('myotherlist', Value));
  CheckEquals('two', Value);

  CheckTrue(FRedis.RPOPLPUSH('mylist', 'myotherlist', Value));
  CheckEquals('one', Value);
  CheckTrue(FRedis.RPOP('myotherlist', Value));
  CheckEquals('one', Value);

  CheckFalse(FRedis.RPOPLPUSH('mylist', 'myotherlist', Value));
  CheckEquals('', Value);
end;

procedure TestRedisClient.TestRPUSHX_LPUSHX;
begin
  FRedis.DEL(['mylist']);
  // mylist doesn't exists, so RPUSHX doesn't create it.
  CheckEquals(0, FRedis.RPUSHX('mylist', ['one']));
  CheckEquals(0, FRedis.LLEN('mylist'));

  // RPUSH creates mylist
  CheckEquals(1, FRedis.RPUSH('mylist', ['one']));
  CheckEquals(1, FRedis.LLEN('mylist'));

  // RPUSHX append to the list
  CheckEquals(2, FRedis.RPUSHX('mylist', ['two']));

  FRedis.DEL(['mylist']);
  CheckEquals(0, FRedis.LPUSHX('mylist', ['one']));
  CheckEquals(0, FRedis.LLEN('mylist'));
end;

procedure TestRedisClient.TestRPUSH_RPOP;
var
  Value: string;
begin
  FRedis.DEL(['mylist']);
  FRedis.RPUSH('mylist', ['one', 'two', 'three']);

  CheckTrue(FRedis.RPOP('mylist', Value));
  CheckEquals('three', Value);

  CheckTrue(FRedis.RPOP('mylist', Value));
  CheckEquals('two', Value);

  CheckTrue(FRedis.RPOP('mylist', Value));
  CheckEquals('one', Value);

  CheckEquals(False, FRedis.RPOP('mylist', Value));
end;

procedure TestRedisClient.TestSELECT;
var
  lRes: string;
begin
  FRedis.SELECT(0);
  FRedis.&SET('db0', 'value0');
  FRedis.SELECT(1);
  CheckFalse(FRedis.GET('db0').HasValue);
  FRedis.SELECT(0);
  lRes := FRedis.GET('db0');
  CheckEquals('value0', lRes);
end;

procedure TestRedisClient.TestSetGet;
var
  Res: string;
begin
{$WARN SYMBOL_DEPRECATED OFF}
  /// ///////////////////////////////////////////////////////
  // DEPRECATION WARNINGS IN THIS TEST ARE OK! DO NOT CHANGE!
  /// ///////////////////////////////////////////////////////
  CheckTrue(FRedis.&SET('nome', 'Daniele'));
  FRedis.GET('nome', Res);
  CheckEquals('Daniele', Res);

  CheckTrue(FRedis.&SET('no"me', 'Dan"iele'));
  CheckTrue(FRedis.GET('no"me', Res));
  CheckEquals('Dan"iele', Res);

  CheckTrue(FRedis.&SET('no"me', 'Dan iele'));
  CheckTrue(FRedis.GET('no"me', Res));
  CheckEquals('Dan iele', Res);
end;

procedure TestRedisClient.TestSetGetUnicode;
var
  Res: TRedisString;
const
  NonStdASCIIValue = '�������@��`';
begin
  CheckTrue(FRedis.&SET('nome', NonStdASCIIValue));
  Res := FRedis.GET('nome');
  CheckTrue(Res.HasValue);
  CheckEquals(NonStdASCIIValue, Res);
end;

procedure TestRedisClient.TestSETRANGE;
var
  lValue: string;
  lBytesValue: TArray<Byte>;
begin
  FRedis.&SET('mykey', '00112233445566778899');
  CheckEquals(20, FRedis.SETRANGE('mykey', 0, 'XX'));
  lValue := FRedis.GET('mykey');
  CheckEquals('XX112233445566778899', lValue);

  FRedis.&SET('mykey', '00112233445566778899');
  CheckEquals(20, FRedis.SETRANGE('mykey', 2, 'XX'));
  lValue := FRedis.GET('mykey');
  CheckEquals('00XX2233445566778899', lValue);

  FRedis.&SET('mykey', '00112233445566778899');
  CheckEquals(20, FRedis.SETRANGE('mykey', 18, 'XX'));
  lValue := FRedis.GET('mykey');
  CheckEquals('001122334455667788XX', lValue);

  FRedis.DEL(['mykey']);
  CheckEquals(4, FRedis.SETRANGE('mykey', 2, 'XY'));
  lBytesValue := FRedis.GET_AsBytes('mykey');

  CheckEquals('00', ByteToHex(lBytesValue[0])); // padded bytes are $00
  CheckEquals('00', ByteToHex(lBytesValue[1])); // padded bytes are $00
  CheckEquals(IntToHex(Ord('X'), 2), ByteToHex(lBytesValue[2]));
  CheckEquals(IntToHex(Ord('Y'), 2), ByteToHex(lBytesValue[3]));
end;

procedure TestRedisClient.TestSTRLEN;
begin
  FRedis.DEL(['mykey']);
  CheckEquals(0, FRedis.STRLEN('mykey'), 'Len of a not exists key is not zero');
  FRedis.APPEND('mykey', '1234');
  CheckEquals(4, FRedis.STRLEN('mykey'), 'Wrong length');
  FRedis.APPEND('mykey', '5678');
  CheckEquals(8, FRedis.STRLEN('mykey'), 'Wrong length');
end;

procedure TestRedisClient.TestWATCH_Fail;
var
  lValue: string;
  lOtherClient: IRedisClient;
begin
  lOtherClient := NewRedisClient;
  FRedis.&SET('mykey', '1234');
  FRedis.WATCH(['mykey']);
  lValue := FRedis.GET('mykey');
  lOtherClient.&SET('mykey', '1111'); // another client change the watched key!
  ExpectedException := ERedisException;
  FRedis.MULTI(
    procedure(const R: IRedisClient)
    begin
      R.&SET('mykey', IntToStr(StrToInt(lValue) + 1));
    end);
end;

procedure TestRedisClient.TestWATCH_MULTI_EXEC_OK;
var
  lValue: string;
  lResp: TRedisArray;
begin
  FRedis.&SET('mykey', '1234');
  FRedis.WATCH(['mykey']);
  lValue := FRedis.GET('mykey');
  FRedis.MULTI;
  CheckTrue(FRedis.InTransaction, 'Is not in transaction when it should');
  FRedis.&SET('mykey', IntToStr(StrToInt(lValue) + 1));
  lResp := FRedis.EXEC;
  CheckTrue(lResp.HasValue);
  Check(Length(lResp.Value) = 1);
  Check(lResp.Value[0] = 'OK');
  CheckFalse(FRedis.InTransaction, 'Is in transaction when it should not');
end;

procedure TestRedisClient.TestWATCH_MULTI_EXEC_Fail;
var
  lValue: string;
  lOtherClient: IRedisClient;
begin
  lOtherClient := NewRedisClient;
  FRedis.&SET('mykey', '1234');
  FRedis.WATCH(['mykey']);
  lValue := FRedis.GET('mykey');
  lOtherClient.&SET('mykey', '1111'); // this invalidate the transaction
  FRedis.MULTI;
  CheckTrue(FRedis.InTransaction, 'Is not in transaction when it should');
  FRedis.&SET('mykey', IntToStr(StrToInt(lValue) + 1));
  try
    FRedis.EXEC;
    fail('No exception efter EXEC');
  except
    on E: Exception do
    begin
      CheckInherits(ERedisException, E.ClassType);
    end;
  end;
  CheckFalse(FRedis.InTransaction, 'Is in transaction when it should not');
end;

procedure TestRedisClient.TestWATCH_OK;
var
  lValue: string;
  lOtherClient: IRedisClient;
begin
  lOtherClient := NewRedisClient;
  FRedis.&SET('mykey', '1234');
  FRedis.WATCH(['mykey']);
  lValue := FRedis.GET('mykey');
  FRedis.MULTI(
    procedure(const R: IRedisClient)
    begin
      R.&SET('mykey', IntToStr(StrToInt(lValue) + 1));
    end);
end;

procedure TestRedisClient.TestZADD_ZRANK_ZCARD;
var
  lValue: Int64;
begin
  FRedis.DEL(['myset']);
  FRedis.ZADD('myset', 1, 'one');
  FRedis.ZADD('myset', 2, 'two');
  FRedis.ZADD('myset', 3, 'three');
  FRedis.ZADD('myset', 4, 'four');
  FRedis.ZADD('myset', 5, 'five');

  CheckEquals(5, FRedis.ZCARD('myset'));
  CheckEquals(0, FRedis.ZCARD('notexists'));

  CheckFalse(FRedis.ZRANK('myset', 'notexists', lValue));

  CheckTrue(FRedis.ZRANK('myset', 'one', lValue));
  CheckEquals(0, lValue);

  CheckTrue(FRedis.ZRANK('myset', 'two', lValue));
  CheckEquals(1, lValue);

  CheckTrue(FRedis.ZRANK('myset', 'three', lValue));
  CheckEquals(2, lValue);

  CheckTrue(FRedis.ZRANK('myset', 'four', lValue));
  CheckEquals(3, lValue);

  CheckTrue(FRedis.ZRANK('myset', 'five', lValue));
  CheckEquals(4, lValue);

end;

// procedure TestRedisClient.TestSUBSCRIBE;
// var
// Rcv: NativeInt;
// MSG: string;
// X: NativeInt;
// begin
// //not implemented
// {
// AtomicExchange(Rcv, 0);
// // It's used for immediate real-time messaging, not for history storage
// FRedis.SUBSCRIBE(['ch1', 'ch2'],
// procedure(Channel, Message: string)
// begin
// MSG := message;
// AtomicIncrement(Rcv, 1);
// end);
// }
// {
// while true do
// begin
// X := AtomicCmpExchange(Rcv, -1, -1);
// TThread.Sleep(100)
// end;
// CheckEquals('hello', MSG);
// }
// end;

initialization

// Register any test cases with the test runner
RegisterTest(TestRedisClient.Suite);

end.
