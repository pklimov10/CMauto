---Хэш файла не совпадает с фактическим значением
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'HASH_CHECKING_FAILED'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'HASH_CHECKING_FAILED'
group by cl_exception.name

---оличество файлов не совпадает с количеством сообщений, содержащих хэш файла
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'ILLEGAL_FILES_COUNT'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'ILLEGAL_FILES_COUNT'
group by cl_exception.name

---Неизвестная ошибка обработки
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'UNKNOWN_EXCEPTION'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'UNKNOWN_EXCEPTION'
group by cl_exception.name
---Отсутствует настройка выходного порта для отправки
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'MISSING_OUTPUT_PORT'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'MISSING_OUTPUT_PORT'
group by cl_exception.name

---Ошибка отправки сообщения в очередь данных

select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'JMS_SENDING_EXCEPTION'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'JMS_SENDING_EXCEPTION'
group by cl_exception.name
---Ошибка настройки очереди данных или фабрики соединений

select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'JMS_CONFIGURATION_EXCEPTION'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'JMS_CONFIGURATION_EXCEPTION'
group by cl_exception.name

---ООшибка получения объекта из системы отправителя
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'CANNOT_GET_OBJECT_FROM_SOURCE'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'CANNOT_GET_OBJECT_FROM_SOURCE'
group by cl_exception.name

---В объекте отсутствуют необходимые для обработки данные
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'ABSENT_DATA_IN_OBJECT'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'ABSENT_DATA_IN_OBJECT'
group by cl_exception.name

---Не найдены получатели сообщения подключенные к КШ
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'NO_RECIPIENT'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'NO_RECIPIENT'
group by cl_exception.name

---Сигнал не относится к документам маршрута
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'WRONG_SIGNAL_TYPE'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'WRONG_SIGNAL_TYPE'
group by cl_exception.name

---Сигнал пропущен. Отправитель не настроен в КШ
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'NO_SENDER'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'NO_SENDER'
group by cl_exception.name

---В объекте JMS-сообщения отсутствуют необходимые свойства
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'ABSENT_JMS_MESSAGE_PROPERTIES'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'ABSENT_JMS_MESSAGE_PROPERTIES'
group by cl_exception.name

---Сигнал пропущен. Документ не зарегистрирован
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'NOT_REGISTERED'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'NOT_REGISTERED'
group by cl_exception.name

---Объект в стадии проект или удален
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'PROJECT_OR_DELETE'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'PROJECT_OR_DELETE'
group by cl_exception.name

---Отмена доставки. Достигнуто максимальное количество попыток
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'MAX_TRY_COUNT'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'MAX_TRY_COUNT'
group by cl_exception.name

---В chLog указан не поддерживаемый тип документа
select
	count(*)
from cmi_msg_in
	join cl_exception
		on cmi_msg_in.exception = cl_exception.id and cmi_msg_in.exception_type = cl_exception.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'CHLOG_NO_IDS'
group by cl_exception.name
UNION

select
	count(*)
from cmi_msg_out
	join cl_exception
		on cmi_msg_out.exception = cl_exception.id and cmi_msg_out.exception_type = cl_exception.id_type
	join cmi_msg_in
		on cmi_msg_out.msgin = cmi_msg_in.id and cmi_msg_out.msgin_type = cmi_msg_in.id_type
	join cmi_route
		on cmi_msg_in.route = cmi_route.id and cmi_msg_in.route_type = cmi_route.id_type
where cmi_route.name like 'SED_EP_RSHB_INPUT' and cl_exception.name = 'CHLOG_NO_IDS'
group by cl_exception.name