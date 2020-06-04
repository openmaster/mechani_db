DROP FUNCTION sp.adjustment(
    _part_id            BIGINT,
    _site_id            BIGINT,
    _adjustment         SMALLINT,
    _reason             TEXT,
    _created_by         BIGINT 
);
DROP TABLE pb.qoh;