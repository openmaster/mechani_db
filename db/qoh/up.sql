CREATE TABLE pb.qoh (
    part_id      BIGINT NOT NULL REFERENCES pb.parts(id),
    site_id      BIGINT NOT NULL REFERENCES core.sites(id),
    adjustment   SMALLINT NOT NULL,
    reason       TEXT NOT NULL,
    created_by   BIGINT NOT NULL REFERENCES core.users(id),
    created      TIMESTAMP NOT NULL DEFAULT current_timestamp
);

CREATE FUNCTION sp.adjustment(
    _part_id            BIGINT,
    _site_id            BIGINT,
    _adjustment         SMALLINT,
    _reason             TEXT,
    _created_by         BIGINT 
) RETURNS TEXT AS $$
DECLARE
    _total SMALLINT;
BEGIN
INSERT INTO pb.qoh (
    part_id,
    site_id,
    adjustment,
    reason,
    created_by,
    created
) VALUES (
    _part_id,
    _site_id,
    _adjustment,
    _reason,
    _created_by,
    current_timestamp
);
select into _total sum(adjustment) from pb.qoh 
        WHERE part_id = _part_id;

update pb.parts set qoh = _total where id = _part_id;
RETURN 'added';
END;
$$LANGUAGE plpgsql;