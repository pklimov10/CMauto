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