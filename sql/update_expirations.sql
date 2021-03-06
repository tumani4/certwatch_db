\timing on

\set ON_ERROR_STOP on

DO
$$DECLARE
	l_ca		RECORD;
	t_counts	bigint[];
BEGIN
	FOR l_ca IN (
		SELECT ca.ID
			FROM ca
			WHERE ca.NEXT_NOT_AFTER < date_trunc('second', now() AT TIME ZONE 'UTC')
			ORDER BY ca.NEXT_NOT_AFTER
	) LOOP
		SELECT *
			INTO t_counts
			FROM update_expirations(l_ca.ID, '10 minutes'::interval);
		COMMIT;
		RAISE NOTICE 'CA ID: %    # Certs Expired: %    # Precerts Expired: %', l_ca.ID, coalesce(t_counts[1], 0), coalesce(t_counts[2], 0);
	END LOOP;
END$$;
