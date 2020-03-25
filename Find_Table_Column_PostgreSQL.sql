SELECT distinct table_catalog, table_schema, table_name
            --, column_name, data_type, is_nullable, character_maximum_length
            , concat('SELECT ''', table_name, ''' as table_name, * FROM ', table_name, ' limit 10;') as SelectTop
       FROM information_schema.columns
       WHERE 1=1
             AND table_schema = 'public'
             AND table_name LIKE '%search%'
             --AND column_name LIKE '%user%'
       ORDER BY 1,2,3,4;