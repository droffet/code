```
// ВНИМАНИЕ! Данные строки расписаны не в учебных целях, а в качестве демонстрации своих знаний - не более.

#include <a_samp.inc>   // Основная библиотека для взаимодействия с функциями сервера.
#include <a_mysql.inc>  // Страница на git: https://github.com/pBlueG/SA-MP-MySQL

main(){}

#define MAX_PLAYER_PASSWORD 24 // Дефайн для максимального пароля игрока.

enum player_info { // Енум, в котором будут объявлены переменные игрока.
    p_name[MAX_PLAYER_NAME], // Переменная в котором будет храниться Nick_Name игрока. Максимальная длинна ника игрока 24 символа. Это ограничение от клиента игры.
    p_password[MAX_PLAYER_PASSWORD] //Переменная в котором будет храниться пароль от игрового аккаунта игрока. Максимальная пароля игрока 24 символа.
}

new MYSQL:DataBase,
    str[256],
    p_info[MAX_PLAYERS][player_info]; // Двумерный массив, в котором будут храниться Nick_Name'ы и пароли всех игроков на сервере. MAX_PLAYERS = 1000. Максимальное количество игроков, ограничение игроков от сервера.

public OnGameModeInit() // Автовызываемая функция, срабатывает - когда сервер запускается.
{
    DataBase = mysql_connect("127.0.0.1", "login", "password", "base_name");
    /*
    mysql_connect(); - это функция, которая использует свои аргументы в качестве настроек для подключения к базе данных MYSQL через панель phpMyAdmin.
    mysql_connect(); - возвращает уникальный индификатор подключения к базе данных.
    */
    return 1;
}

public OnPlayerConnect(playerid) // Автовызываемая функция, срабатывает - когда к включенному серверу подключатся игрок.
{
    GetPlayerName(playerid, p_info[playerid][p_name], MAX_PLAYER_NAME);

    /*
    playerid - глобальная переменная, в которой сохраняется уникальный индификатор игрока на сервере.
    В данном случае, мы получаем id игрока, которые подключился к серверу

    GetPlayerName(); - сохраняет Nick_Name игрока во втором аргументе.
    Nick_Name - устанавливается при заходе на сервер самим игроком.
    */

    mysql_format(DataBase, str, sizeof(str), "SELECT * FROM `users` WHERE `p_name` = '%s' LIMIT 1", p_info[playerid][p_name]); // Форматируем строку для запроса.
    new row, Cache:result = mysql_query(DataBase, str, true); // Эта функция отправляет запрос на определенный MYSQL сервер, который вернет определенные значения.
    cache_get_row_count(row); // cache_get_row_count(row); - присваивает своему аргументу количество строк, которые вернул сервер MYSQL.
    // ЕСЛИ row РАВНО 0 - значит, в базе данных нету строки с Nick_Name'ом нашего игрока, а следовательно - у игрока нету аккаунта.
    // ЕСЛИ row НЕ РАВНО 0 - значит, в базе данных есть строка с Nick_Name'ом нашего игрока, а следовательно - аккаунт создан.
    if(row == 0) create_account(playerid); // Отправляем игрока создавать аккаунт.
    else if(row != 0) // Отправляем игрока авторизовываться.
    {
        cache_get_value_name(0, "p_password", p_info[playerid][p_password], MAX_PLAYER_PASSWORD); // Функция для присвоения массива из базы данных к третьему аргументу. Массив извлекается из ячейки в базе данных.
        login_account(playerid);
    }
    cache_delete(result);
    return 1;
}

forward create_account(playerid);
public create_account(playerid)
{
    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, "Регистрация", "Введите ваш пароль для регистрации аккаунта.", "Ввод", "Отмена");
    // ShowPlayerDialog(); - это функция для создания простейшего внутриигрового интерфейса с информацией. В данном случае, у игрока открывается окно - в котором нужно ввести новый пароль.
    return 1;
}

forward login_account(playerid);
public login_account(playerid)
{
    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Авторизация", "Введите ваш пароль от аккаунта.", "Ввод", "Отмена");
    // ShowPlayerDialog(); - это функция для создания простейшего внутриигрового интерфейса с информацией. В данном случае, у игрока открывается окно - в котором нужно ввести пароль.
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) // Автовызываемая функция, срабатывает - когда игрок как либо взаимодействует с внутриигровым интерфейсом.
{
    switch(dialogid) // dialogid - это аргумент, который содержит в себе уникальный индификатор интерфейса. Он указывается при создании интерфейса ShowPlayerDialog(); - второй аргумент.
    {
        case 0:
        {
            if(!response) { // У интерфейсов бывает 2 кнопки, данное условие срабатывает - когда игрок нажимает на вторую кнопку "Отмена".
                return create_account(playerid); } // Возвращаем игрока обратно в интерфейс.
            if(strlen(inputtext) > MAX_PLAYER_PASSWORD || strlen(inputtext) == 0) { // strlen(); - возвращает количество символов в массиве. Если их больше 24 или вообще нету, то пароль введен не корректно.
                return create_account(playerid); } // Возвращаем игрока обратно в интерфейс.
            for(new i; i < strlen(inputtext); i++) // Проверяем каждый символ, если в массиве есть символ который не будет цифрой или есть пробел, то отправляем игрока снова вводить пароль.
            {
                switch(inputtext[i])
                {
                    case '0'..'9': continue;
                    case ' ': return create_account(playerid);
                    default: return create_account(playerid);
                }
            }
            strcat(p_info[playerid][p_password], inputtext); // Прикрепляем  массив inputtext к нашему пустому массиву p_password.
            mysql_format(DataBase, str, sizeof(str), "INSERT INTO `users` (`p_name`, `p_password`) VALUES ('%s', '%s')", p_info[playerid][p_name], p_info[playerid][p_password]);
            mysql_query(DataBase, str, false);
            print("Регистрация прошла успешно.");
            // Успех, игрок зарегистрировался.
        }
        case 1:
        {
            if(!response) { // У интерфейсов бывает 2 кнопки, данное условие срабатывает - когда игрок нажимает на вторую кнопку "Отмена".
                return login_account(playerid); } // Возвращаем игрока обратно в интерфейс.
            if(strlen(inputtext) > MAX_PLAYER_PASSWORD || strlen(inputtext) == 0) { // strlen(); - возвращает количество символов в массиве. Если их больше 24 или вообще нету, то пароль введен не корректно.
                return login_account(playerid); } // Возвращаем игрока обратно в интерфейс.
            for(new i; i < strlen(inputtext); i++) // Проверяем каждый символ, если в массиве есть символ который не будет цифрой или есть пробел, то отправляем игрока снова вводить пароль.
            {
                switch(inputtext[i])
                {
                    case '0'..'9': continue;
                    case ' ': return login_account(playerid);
                    default: return login_account(playerid);
                }
            }
            if(strcmp(inputtext, p_info[playerid][p_password], false) == 0) // strcmp(); - сравнивает строки на предмет совпадения. Если строки совпадают, то функция возвращает 0.
            {
                print("Авторизация прошла успешно.");
                // Успех, игрок авторизовался.
            }
        }
    }
    return 1;
}
