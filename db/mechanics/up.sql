CREATE TABLE core.job_mechanics (
  job_id        BIGINT NOT NULL REFERENCES core.jobs(id),
  mechanic_id   BIGINT NOT NULL REFERENCES core.users(id),
  work_time_log JSONB,
  total_duration   Text,
  created TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (job_id, mechanic_id)
);

CREATE FUNCTION sp.job_mechanics (_job_id BIGINT, _mechanic_id BIGINT, _work_time_log JSONB, _total_duration TEXT) RETURNS TEXT AS $$
DECLARE
  _row RECORD;
  _new_id RECORD;
BEGIN
  SELECT INTO _row * FROM core.job_mechanics WHERE job_id = _job_id and mechanic_id = _mechanic_id;
  IF FOUND THEN
    UPDATE core.job_mechanics SET work_time_log = _work_time_log, total_duration = _total_duration, updated = current_timestamp WHERE job_id = _job_id and mechanic_id = _mechanic_id;
    RETURN 'UPDATED';
  ELSE
    INSERT INTO core.job_mechanics (job_id, mechanic_id, work_time_log, total_duration) VALUES (_job_id, _mechanic_id, _work_time_log, _total_duration) RETURNING job_id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;
