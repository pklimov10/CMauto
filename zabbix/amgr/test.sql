
---Агенты asup включеные
SELECT
  trigger.title
FROM
  am_agent_trigger trigger
JOIN
  domain_object_type_id domain
    ON domain.id = trigger.id_type
WHERE
  domain.name = 'am_agent_trigger' AND
  trigger.enabled = '1';

---Агенты asup выключеные
SELECT
  trigger.title
FROM
  am_agent_trigger trigger
JOIN
  domain_object_type_id domain
    ON domain.id = trigger.id_type
WHERE
  domain.name = 'am_agent_trigger' AND
  trigger.enabled = '0';

---Агенты по расписанию выключеные
SELECT
  trigger.title
FROM
  am_agent_trigger trigger
JOIN
  domain_object_type_id domain
    ON domain.id = trigger.id_type
WHERE
  domain.name = 'am_sched_agent_trigger' AND
  trigger.enabled = '0';

---Агенты по расписанию включенные
SELECT
  trigger.title
FROM
  am_agent_trigger trigger
JOIN
  domain_object_type_id domain
    ON domain.id = trigger.id_type
WHERE
  domain.name = 'am_sched_agent_trigger' AND
  trigger.enabled = '1';



--Статус и лог включеных агентов по расписанию

SELECT DISTINCT ON(1)
  trigger.title AS "Имя агента"
, amm.execution_status AS "Статус последний обработки"
, log.execution_log AS "Лог обработки"
, amm.created_date AS "Дата обработки"
FROM
  am_trigger_executions amm
JOIN
  am_agent_trigger trigger
    ON trigger.id = amm.owner
JOIN
  am_trigger_agent_exec exec
    ON exec.owner = amm.id
JOIN
  am_agent_exec_log log
    ON log.owner = exec.id
JOIN
  domain_object_type_id domain
    ON domain.id = trigger.id_type
WHERE
  domain.name = 'am_sched_agent_trigger' AND --тип агента по расписанию
  trigger.enabled = '1'
ORDER BY
  1
, amm.created_date DESC;

---Агенты asup включеные по. врмени выводим только те агенты где была ошибка в логе или выозращен кривой статстус


SELECT DISTINCT ON(1)
  trigger.title AS "Имя агента"
, amm.execution_status AS "Статус последний обработки"
, log.execution_log AS "Лог обработки"
, amm.created_date AS "Дата обработки",
log.created_date
FROM
  am_trigger_executions amm
JOIN
  am_agent_trigger trigger
    ON trigger.id = amm.owner
JOIN
  am_trigger_agent_exec exec
    ON exec.owner = amm.id
 JOIN
  am_agent_exec_log log
    ON log.owner = exec.id
JOIN
  domain_object_type_id domain
    ON domain.id = trigger.id_type
WHERE
  domain.name = 'am_agent_trigger' AND -- тип агента ASUP
  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '3600' DAY --Поменять на нужную дату
ORDER BY
  1
, amm.created_date DESC;

--- Вывод ошибочных агентов по расписнию

WITH agent_list AS (
  SELECT DISTINCT ON(1)
    trigger.title
  , amm.execution_status
  , log.execution_log
  , amm.created_date
  FROM
    am_trigger_executions amm
  JOIN
    am_agent_trigger trigger
      ON trigger.id = amm.owner
  JOIN
    am_trigger_agent_exec exec
      ON exec.owner = amm.id
  JOIN
    am_agent_exec_log log
      ON log.owner = exec.id
  JOIN
    domain_object_type_id domain
      ON domain.id = trigger.id_type
  WHERE
    domain.name = 'am_sched_agent_trigger' AND
    trigger.enabled = '1'
  ORDER BY
    1
  , amm.created_date DESC
)
SELECT
  *
FROM
  agent_list
WHERE
  execution_status = 'ERROR';

--- Вывод ошибочных агентов по с ошибкой в логе

WITH agent_list AS (
  SELECT DISTINCT ON(1)
    trigger.title
  , amm.execution_status
  , log.execution_log
  , amm.created_date
  FROM
    am_trigger_executions amm
  JOIN
    am_agent_trigger trigger
      ON trigger.id = amm.owner
  JOIN
    am_trigger_agent_exec exec
      ON exec.owner = amm.id
  JOIN
    am_agent_exec_log log
      ON log.owner = exec.id
  JOIN
    domain_object_type_id domain
      ON domain.id = trigger.id_type
  WHERE
    domain.name = 'am_sched_agent_trigger' AND
    trigger.enabled = '1'
  ORDER BY
    1
  , amm.created_date DESC
)
SELECT
  *
FROM
  agent_list
WHERE
  execution_log LIKE '%неуспешно%' OR execution_log LIKE '%java%' OR execution_log  LIKE   '%Exception%';
