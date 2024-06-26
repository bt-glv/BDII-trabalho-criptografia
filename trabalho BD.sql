/*
	BDII
	BRNUO TELES GALVAO - 72200332 
*/



	-- setup and test code INICIO
set serveroutput on;

create table login
(
	cod_login number constraint pk primary key
	,login varchar2(30)
	,senha varchar2(150)
);

create table acesso
(
	data_hora timestamp, 
	cod_login number constraint fk references login(cod_login)
);
	-- setup FIM



--
--	Questao 1 - 2
--

-- Area de teste INICIO
select fn_criptografia('COTEMIG123',3) from dual;
-- Area de teste FIM

create or replace function fn_criptografia(senha varchar2, acrescimo number)
return varchar2
as
	lean number;

	loop_3 boolean;
	loop_3_nu number;
	after_scramble varchar2(300):='';

	loop_4_str varchar2(300);
	after_acsii varchar2(300):='';

begin

    select length(senha) into lean from dual;
    if lean < 1 then
        return '';
    end if;


    -- Encrypt loop INICIO
    loop_3_nu:=1;
    for loop_2 in 0 .. 2 loop

        loop_3_nu:=loop_2;
        loop_3:=true;
        while loop_3 loop

            if loop_3_nu >= lean
            then
                loop_3:=false;
            else
                after_scramble:=after_scramble||substr(senha, loop_3_nu+1,1);
                loop_3_nu:=loop_3_nu+3;
            end if;


        end loop;

    end loop;
-- Encrypt loop FIM

-- To ascii INICIO
	for loop_4 in 0..lean-1 loop

		loop_4_str:=substr(after_scramble, loop_4+1, 1);
		loop_4_str:=to_char(ascii(loop_4_str));
		loop_4_str:=to_char(to_number(loop_4_str)+acrescimo);

		if to_number(loop_4_str) < 10 then
			loop_4_str:='00'||loop_4_str;
		end if;

		if to_number(loop_4_str) < 100 then 
			loop_4_str:='0'||loop_4_str;
		end if;


		after_acsii:=after_acsii||loop_4_str;

	end loop;
-- To ascii FIM



	return after_acsii;
end;
/



--
--	Questao 03
--

-- Area de teste INICIO
	select fn_descriptografia('070072074054082080052087076053',3) from dual;
-- Area de teste INICIO

create or replace function fn_descriptografia(senha varchar2, acrescimo number)
return varchar2
as
	lean number:=length(senha);
	after_acsii varchar(300):='';
	after_scramble varchar (300):='';
	final varchar2(300):='';
	
	loop_1_nu number;

	loop_2_nu number;
	extra number;
	without_extra number;
	extra_elements varchar2(300):='';
	group_size number;
	extra_size dbms_sql.number_table;


begin 
	-- ascii decript INICIO
	loop_1_nu:=1;
	for loop_1 in 0..lean loop

		if loop_1_nu+3 > lean+1 then
			exit;
		end if;

		after_acsii:=after_acsii||chr(to_number(substr(senha,loop_1_nu,3))-acrescimo);
		loop_1_nu:=loop_1_nu+3;

	end loop;
	-- ascii decript FIM


	-- Decrypt loop INICIO
		
		lean:=length(after_acsii);
		extra:=mod(lean,3);
		without_extra:=lean-extra;
		
		group_size:=without_extra/3;

		extra_size(0):=0;
		extra_size(1):=0;

		if extra > 0 then

			extra_elements:=substr(after_acsii, group_size+1,1);
			extra_size(0):=1;
			if extra = 2 
			then
				extra_elements:=extra_elements||substr(after_acsii, (group_size+1)*2, 1);
				extra_size(1):=1;
			end if;
		end if;


		loop_2_nu:=0;
		for xxx in 1..group_size loop
		
				after_scramble:=after_scramble||substr(after_acsii, xxx, 1);
				after_scramble:=after_scramble||substr(after_acsii, xxx+group_size+extra_size(0), 1);
				after_scramble:=after_scramble||substr(after_acsii, xxx+(group_size*2)+extra_size(1)+extra_size(0), 1);
		end loop;

		after_scramble:=after_scramble||extra_elements;

	-- Decrypt loop FIM


	return after_scramble;
end;
/



--	
--	Questao 4	
--	

--	Area de teste INICIO
select * from login;
select * from acesso;
call pr_insere_login(1, 'Adalberto', 'asdf');

set serveroutput on;
--	Area de teste FIM

create or replace procedure pr_insere_login(in_cod_login number, in_login varchar2, senha varchar2)
is

	cursor check_login is
	select cod_login, login
	from login;

	check_login_count number;

	now_timestamp number;
	now_timestamp_true timestamp;
	after_encryption varchar(300);

begin

	select count(cod_login) into check_login_count from login where cod_login = in_cod_login;
	if check_login_count >= 1 then
		raise_application_error(-20001, 'O campo cod_login informado esta repetido na tabela.');
	end if;


	select count(cod_login) into check_login_count from login where lower(login) = lower(in_login);
	if check_login_count >= 1 then
		raise_application_error(-20001, 'O campo login informado esta repetido na tabela.');
	end if;


	now_timestamp_true:=systimestamp;
	now_timestamp:=to_number(to_char(now_timestamp_true,'FF1'));


	select fn_criptografia(senha, now_timestamp) into after_encryption from dual;


	insert into login values (in_cod_login, in_login, after_encryption);
	insert into acesso values (now_timestamp_true, in_cod_login);

	dbms_output.put_line('O login foi inserido com sucesso!');
end;
/



--
--	Questao 5
--


--	Area de teste INICIO
call pr_valida_login('DAdalberto', 'asdf');

set serveroutput on;
select * from login;
select * from acesso;
--	Area de teste FIM

create or replace procedure pr_valida_login(in_login varchar2, in_senha varchar2)
is

	login_existance_check varchar2(300);
	login_cod number;

	acrescimo timestamp;
	acrescimo_number number;

	encryption_result varchar2(300);
	current_password varchar2(300);

	new_acrescimo timestamp;
	new_acrescimo_number number;
	new_password varchar2(300);

begin
	
	begin
		select l.cod_login into login_cod from login l where lower(l.login) = lower(in_login);
	exception when NO_DATA_FOUND then
		raise_application_error(-20002, 'O login informado nao existe');
	end;


	SELECT data_hora into acrescimo
	FROM 
	(
     	SELECT i.*,
     	ROW_NUMBER() OVER (ORDER BY data_hora DESC) AS rn
     	FROM acesso i
	where cod_login = login_cod
	)
	WHERE rn = 1;


	acrescimo_number:=to_number(to_char(acrescimo, 'FF1'));
	encryption_result:=fn_criptografia(in_senha, acrescimo_number);
	select senha into current_password from login where cod_login = login_cod;


	if current_password = encryption_result then


		dbms_output.put_line('O login inserido foi validado com sucesso!');

		new_acrescimo:=systimestamp;	
		new_acrescimo_number:=to_number(to_char(new_acrescimo, 'FF1'));
		new_password:=fn_criptografia(fn_descriptografia(current_password, acrescimo_number), new_acrescimo_number);


		insert into acesso values (new_acrescimo, login_cod);
		update login set senha = new_password where cod_login = login_cod;


	else
		dbms_output.put_line('Login invalido');
	end if;
end;
/
