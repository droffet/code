// ��������! ������ ������ ��������� �� � ������� �����, � � �������� ������������ ����� ������ - �� �����.

#include <a_samp.inc>   // �������� ���������� ��� �������������� � ��������� �������.
#include <a_mysql.inc>  // �������� �� git: https://github.com/pBlueG/SA-MP-MySQL

main(){}

#define MAX_PLAYER_PASSWORD 24 // ������ ��� ������������� ������ ������.

enum player_info { // ����, � ������� ����� ��������� ���������� ������.
    p_name[MAX_PLAYER_NAME], // ���������� � ������� ����� ��������� Nick_Name ������. ������������ ������ ���� ������ 24 �������. ��� ����������� �� ������� ����.
    p_password[MAX_PLAYER_PASSWORD] //���������� � ������� ����� ��������� ������ �� �������� �������� ������. ������������ ������ ������ 24 �������.
}

new MYSQL:DataBase,
    str[256],
    p_info[MAX_PLAYERS][player_info]; // ��������� ������, � ������� ����� ��������� Nick_Name'� � ������ ���� ������� �� �������. MAX_PLAYERS = 1000. ������������ ���������� �������, ����������� ������� �� �������.

public OnGameModeInit() // �������������� �������, ����������� - ����� ������ �����������.
{
    DataBase = mysql_connect("127.0.0.1", "login", "password", "base_name");
    /*
    mysql_connect(); - ��� �������, ������� ���������� ���� ��������� � �������� �������� ��� ����������� � ���� ������ MYSQL ����� ������ phpMyAdmin.
    mysql_connect(); - ���������� ���������� ����������� ����������� � ���� ������.
    */
    return 1;
}

public OnPlayerConnect(playerid) // �������������� �������, ����������� - ����� � ����������� ������� ����������� �����.
{
    GetPlayerName(playerid, p_info[playerid][p_name], MAX_PLAYER_NAME);

    /*
    playerid - ���������� ����������, � ������� ����������� ���������� ����������� ������ �� �������.
    � ������ ������, �� �������� id ������, ������� ����������� � �������

    GetPlayerName(); - ��������� Nick_Name ������ �� ������ ���������.
    Nick_Name - ��������������� ��� ������ �� ������ ����� �������.
    */

    mysql_format(DataBase, str, sizeof(str), "SELECT * FROM `users` WHERE `p_name` = '%s' LIMIT 1", p_info[playerid][p_name]); // ����������� ������ ��� �������.
    new row, Cache:result = mysql_query(DataBase, str, true); // ��� ������� ���������� ������ �� ������������ MYSQL ������, ������� ������ ������������ ��������.
    cache_get_row_count(row); // cache_get_row_count(row); - ����������� ������ ��������� ���������� �����, ������� ������ ������ MYSQL.
    // ���� row ����� 0 - ������, � ���� ������ ���� ������ � Nick_Name'�� ������ ������, � ������������� - � ������ ���� ��������.
    // ���� row �� ����� 0 - ������, � ���� ������ ���� ������ � Nick_Name'�� ������ ������, � ������������� - ������� ������.
    if(row == 0) create_account(playerid); // ���������� ������ ��������� �������.
    else if(row != 0) // ���������� ������ ����������������.
    {
        cache_get_value_name(0, "p_password", p_info[playerid][p_password], MAX_PLAYER_PASSWORD); // ������� ��� ���������� ������� �� ���� ������ � �������� ���������. ������ ����������� �� ������ � ���� ������.
        login_account(playerid);
    }
    cache_delete(result);
    return 1;
}

forward create_account(playerid);
public create_account(playerid)
{
    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "�����������", "������� ��� ������ ��� ����������� ��������.", "����", "������");
    // ShowPlayerDialog(); - ��� ������� ��� �������� ����������� �������������� ���������� � �����������. � ������ ������, � ������ ����������� ���� - � ������� ����� ������ ����� ������.
    return 1;
}

forward login_account(playerid);
public login_account(playerid)
{
    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "�����������", "������� ��� ������ �� ��������.", "����", "������");
    // ShowPlayerDialog(); - ��� ������� ��� �������� ����������� �������������� ���������� � �����������. � ������ ������, � ������ ����������� ���� - � ������� ����� ������ ������.
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) // �������������� �������, ����������� - ����� ����� ��� ���� ��������������� � ������������� �����������.
{
    switch(dialogid) // dialogid - ��� ��������, ������� �������� � ���� ���������� ����������� ����������. �� ����������� ��� �������� ���������� ShowPlayerDialog(); - ������ ��������.
    {
        case 0:
        {
            if(!response) { // � ����������� ������ 2 ������, ������ ������� ����������� - ����� ����� �������� �� ������ ������ "������".
                return create_account(playerid); } // ���������� ������ ������� � ���������.
            if(strlen(inputtext) > MAX_PLAYER_PASSWORD || strlen(inputtext) == 0) { // strlen(); - ���������� ���������� �������� � �������. ���� �� ������ 24 ��� ������ ����, �� ������ ������ �� ���������.
                return create_account(playerid); } // ���������� ������ ������� � ���������.
            for(new i; i < strlen(inputtext); i++) // ��������� ������ ������, ���� � ������� ���� ������ ������� �� ����� ������ ��� ���� ������, �� ���������� ������ ����� ������� ������.
            {
                switch(inputtext[i])
                {
                    case '0'..'9': continue;
                    case ' ': return create_account(playerid);
                    default: return create_account(playerid);
                }
            }
            strcat(p_info[playerid][p_password], inputtext); // �����������  ������ inputtext � ������ ������� ������� p_password.
            mysql_format(DataBase, str, sizeof(str), "INSERT INTO `users` (`p_name`, `p_password`) VALUES ('%s', '%s')", p_info[playerid][p_name], p_info[playerid][p_password]);
            mysql_query(DataBase, str, false);
            print("����������� ������ �������.");
            // �����, ����� �����������������.
        }
        case 1:
        {
            if(!response) { // � ����������� ������ 2 ������, ������ ������� ����������� - ����� ����� �������� �� ������ ������ "������".
                return login_account(playerid); } // ���������� ������ ������� � ���������.
            if(strlen(inputtext) > MAX_PLAYER_PASSWORD || strlen(inputtext) == 0) { // strlen(); - ���������� ���������� �������� � �������. ���� �� ������ 24 ��� ������ ����, �� ������ ������ �� ���������.
                return login_account(playerid); } // ���������� ������ ������� � ���������.
            for(new i; i < strlen(inputtext); i++) // ��������� ������ ������, ���� � ������� ���� ������ ������� �� ����� ������ ��� ���� ������, �� ���������� ������ ����� ������� ������.
            {
                switch(inputtext[i])
                {
                    case '0'..'9': continue;
                    case ' ': return login_account(playerid);
                    default: return login_account(playerid);
                }
            }
            if(strcmp(inputtext, p_info[playerid][p_password], false) == 0) // strcmp(); - ���������� ������ �� ������� ����������. ���� ������ ���������, �� ������� ���������� 0.
            {
                print("����������� ������ �������.");
                // �����, ����� �������������.
            }
        }
    }
    return 1;
}