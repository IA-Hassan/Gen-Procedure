program generatestoredprocedure;
{$mode objfpc}{$H+}
uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,sysutils ,crt
  { you can add units after this };
var
  ProcName, TableName, FieldName, FieldType, PrimaryKey: string;
  FieldsList, ParamsList, InsertFieldsList, InsertValuesList: TStringList;
  i: Integer;
  SQLFile: TextFile;

begin
   ClrScr;
  // Initialisation des listes
  FieldsList := TStringList.Create;
  ParamsList := TStringList.Create;
  InsertFieldsList := TStringList.Create;
  InsertValuesList := TStringList.Create;

  // Demande du nom de la procédure stockée
  Write('Entrez le nom de la procédure stockée : ');
  ReadLn(ProcName);

  // Demande du nom de la table
  Write('Entrez le nom de la table : ');
  ReadLn(TableName);

  // Saisie des champs et types
  Writeln('Entrez les champs et leurs types (ex: id INT, name VARCHAR(100)). Entrez "STOP" pour terminer.');
  repeat
    Write('Nom du champ : ');
    ReadLn(FieldName);
    if UpperCase(FieldName) <> 'STOP' then
    begin
      Write('Type du champ : ');
      ReadLn(FieldType);
      FieldsList.Add(FieldName + ' ' + FieldType);
      ParamsList.Add('IN p_' + FieldName + ' ' + FieldType);
      InsertFieldsList.Add(FieldName);
      InsertValuesList.Add('p_' + FieldName);
    end;
  until UpperCase(FieldName) = 'STOP';

  // Suppression de la dernière entrée "STOP" si existante
  if FieldsList.Count > 0 then
    FieldsList.Delete(FieldsList.Count - 1);

  // Sélection du champ clé primaire pour la vérification de l'existence
  Write('Entrez le nom du champ clé primaire (ex: id) : ');
  ReadLn(PrimaryKey);

  // Génération du script SQL
  AssignFile(SQLFile, ProcName+'.sql');
  Rewrite(SQLFile);

  Writeln(SQLFile, 'DELIMITER $$');
  Writeln(SQLFile, 'CREATE PROCEDURE ', ProcName, '(');
  Writeln(SQLFile, '  ', ParamsList.Text, ',');
  Writeln(SQLFile, '  OUT out_result BOOLEAN');
  Writeln(SQLFile, ')');
  Writeln(SQLFile, 'BEGIN');
  Writeln(SQLFile, '  DECLARE client_count INT;');
  Writeln(SQLFile, '  START TRANSACTION;');
  Writeln(SQLFile, '  SELECT COUNT(*) INTO client_count FROM ', TableName, ' WHERE ', PrimaryKey, ' = p_', PrimaryKey, ';');
  Writeln(SQLFile, '  IF client_count = 0 THEN');
  Writeln(SQLFile, '    INSERT INTO ', TableName, ' (', InsertFieldsList.CommaText, ') VALUES (', InsertValuesList.CommaText, ');');
  Writeln(SQLFile, '    SET out_result = TRUE;');
  Writeln(SQLFile, '    COMMIT;');
  Writeln(SQLFile, '  ELSE');
  Writeln(SQLFile, '    SET out_result = FALSE;');
  Writeln(SQLFile, '    ROLLBACK;');
  Writeln(SQLFile, '  END IF;');
  Writeln(SQLFile, 'END$$');
  Writeln(SQLFile, 'DELIMITER ;');

  CloseFile(SQLFile);

  // Libération de la mémoire
  FieldsList.Free;
  ParamsList.Free;
  InsertFieldsList.Free;
  InsertValuesList.Free;

  WriteLn('Procédure stockée générée avec succès dans "generated_procedure.sql" !');
end.



