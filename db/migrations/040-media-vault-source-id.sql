-- Where a MediaVault row came from, so a lookup can be run again exactly.
--
-- Until now the link back to the source record was thrown away the moment an
-- item was saved: fillBookFields wrote four fields and discarded the ISBN it
-- had been handed, and selectTMDBResult wrote year, runtime and rating into
-- notes without ever keeping the TMDB id. So anything wanting to re-run a
-- lookup could only guess from title and author - and OpenLibrary's own search
-- returned 24 results for an ISBN that does not exist, which is how a library
-- gets quietly filled with the wrong covers.
--
-- ONE generic column rather than two nullable ones. It holds the normalised
-- ISBN for a book, and 'tmdb:movie:1234' / 'tmdb:tv:1234' for video, so the
-- prefix says which lookup to run and the rest is that lookup's key. Two
-- columns would mean every reader checking which one is populated, and both
-- would be empty on the same rows anyway.
--
-- Empty string, not NULL: it matches every other text column on this table and
-- keeps sanitizeItem's "missing means ''" rule true for all of them. Existing
-- rows all get '', which is honest - nobody knows where they came from - and
-- is why the backfill in the bulk audit's B6 exists.
ALTER TABLE media_items ADD COLUMN source_id TEXT NOT NULL DEFAULT '';

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('040-media-vault-source-id.sql');
