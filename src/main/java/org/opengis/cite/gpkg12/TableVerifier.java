package org.opengis.cite.gpkg12;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * @author Luke Lambert
 */
public final class TableVerifier
{
    // Not meant to instantiate
    private TableVerifier()
    {

    }

    
    /**
     * Validate a string value to ensure it contains no illegal characters or content and
     * ensure the string is valid if used for a SQLite table or column name. Further, even though
     * SQLite does accept some special characters, we will allow only the underbar special character.
     * 
     * @param inputString The string to validate
     * @return validated string
     * @throws IllegalArgumentException if the input is found to be invalid
     */
    public static String validateSQLiteTableColumnStringInput( String inputString ) throws IllegalArgumentException {

    	StringBuilder sb = new StringBuilder(50);  // initial size is 50. This is expected to be sufficient for most table and field names. This is NOT a limit.
    	for (int ii = 0; ii < inputString.length(); ++ii) {
    		final char cleanedchar = cleanCharSQLite(inputString.charAt(ii));
    		if (cleanedchar == '^') {   // This is an illegal character indicator
    			throw new IllegalArgumentException(String.format("Illegal SQLite column or table name string input %s at character %c",inputString, inputString.charAt(ii)));
    		}
    		else {
    			sb.append(cleanedchar);
    		}
    	}
    	return sb.toString();
    }

    /**
     * Validate a string value to ensure it contains no illegal characters or content and
     * ensure the string is valid for descriptive purposes, including date values.
     * i.e. filter minimal characters.
     * 
     * @param inputString The string to validate
     * @return validated string
     * @throws IllegalArgumentException if the input is found to be invalid
     */
    public static String ValidateDescriptiveStringInput( String inputString ) throws IllegalArgumentException {

    	StringBuilder sb = new StringBuilder(50);  // initial size is 50. This is expected to be sufficient for most table and field names. This is NOT a limit.
    	for (int ii = 0; ii < inputString.length(); ++ii) {
    		final char cleanedchar = cleanDescriptiveChar(inputString.charAt(ii));
    		if (cleanedchar == '`') {   // This is an illegal character indicator
    			throw new IllegalArgumentException(String.format("Illegal descriptive string input %s at character %c",inputString, inputString.charAt(ii)));
    		}
    		else {
    			sb.append(cleanedchar);
    		}
    	}
    	return sb.toString();
    }
    
    /**
     * Validate and clean a character of a string expected to be part of an SQL table or column name
     * 
     * @param inputChar  A character of a string, for which we will check validity, replacing any illegal characters with ^
     * @return a validated character
     */
    private static char cleanCharSQLite(char inputChar) {
        // 0 - 9
        for (int i = 48; i < 58; ++i) {
            if (inputChar == i) return (char) i;
        }

        // 'A' - 'Z'
        for (int i = 65; i < 91; ++i) {
            if (inputChar == i) return (char) i;
        }

        // 'a' - 'z'
        for (int i = 97; i < 123; ++i) {
            if (inputChar == i) return (char) i;
        }

        // other valid characters
        switch (inputChar) {
            case '_':
                return '_';
        }
        return '^';
    }

    /**
     * Validate and clean a character of a string expected to be part of an SQL table or column name
     * 
     * @param inputChar  A character of a string, for which we will check validity, replacing any illegal characters with ^
     * @return a validated character
     */
    private static char cleanDescriptiveChar(char inputChar) {
        // 0 - 9
        for (int i = 48; i < 58; ++i) {
            if (inputChar == i) return (char) i;
        }

        // 'A' - 'Z'
        for (int i = 65; i < 91; ++i) {
            if (inputChar == i) return (char) i;
        }

        // 'a' - 'z'
        for (int i = 97; i < 123; ++i) {
            if (inputChar == i) return (char) i;
        }

        // other valid characters
        switch (inputChar) {
            case '_':
                return '_';
            case '%':
                return '%';
            case ' ':
                return ' ';
            case '-':
                return '-';
            case ':':
                return ':';
            case ',':
                return ',';
            case '.':
                return '.';
            case ';':
                return ';';
            case '(':
                return '(';
            case ')':
                return ')';
            case '+':
                return '+';
            case '=':
                return '=';
            case '*':
                return '*';
            case '&':
                return '&';
            case '$':
                return '$';
            case '#':
                return '#';
            case '@':
                return '@';
            case '^':
                return '^';
            case '\'':
                return '\'';
            case '\\':
                return '\\';
            case '/':
                return '/';
            case '?':
                return '?';
        }
        return '`';
    }

    
    public static void verifyTable(final Connection                    connection,
                                   final String                        tableName,
                                   final Map<String, ColumnDefinition> expectedColumns,
                                   final Set<ForeignKeyDefinition>     expectedForeinKeys,
                                   final Iterable<UniqueDefinition>    expectedGroupUniques) throws SQLException
    {
        verifyTableDefinition(connection, tableName);

        final Set<UniqueDefinition> uniques = getUniques(connection, tableName);   // Assumption: This incoming tableName has been verified if it is user or SQL based input

        verifyColumns(connection,
                      tableName,
                      expectedColumns,
                      uniques);

        verifyForeignKeys(connection,
                          tableName,
                          expectedForeinKeys);

        verifyGroupUniques(tableName,
                           expectedGroupUniques,
                           uniques);
    }

    private static void verifyTableDefinition(final Connection connection, final String tableName) throws SQLException
    {
        try(final PreparedStatement statement = connection.prepareStatement("SELECT sql FROM sqlite_master WHERE (type = 'table' OR type = 'view') AND tbl_name = ?;"))
        {
            statement.setString(1, tableName);		// Assumption: This incoming tableName has been verified if it is user or SQL based input

            try(ResultSet gpkgContents = statement.executeQuery())
            {
                if(gpkgContents.getString("sql") == null)
                {
                    throw new RuntimeException(String.format("The `sql` field must include the %s table SQL Definition.", tableName));  // TODO this needs to be in the error string table
                }
            }
        }
    }

    private static Set<UniqueDefinition> getUniques(final Connection connection, final String tableName) throws SQLException
    {
        try(final Statement statement = connection.createStatement();
            final ResultSet indices   = statement.executeQuery(String.format("PRAGMA index_list(%s);", tableName)))
        {
            final Set<UniqueDefinition> uniqueDefinitions = new HashSet<>();

            while(indices.next())
            {
                if(indices.getBoolean("unique"))
                {
                    final String indexName = validateSQLiteTableColumnStringInput(indices.getString("name"));
                    
                 // FORTIFY CWE
                    try(Statement nameStatement = connection.createStatement();
                        ResultSet namesSet      = nameStatement.executeQuery(String.format("PRAGMA index_info(%s);", indexName)))
                    {
                        final List<String> names = new ArrayList<>();

                        while(namesSet.next())
                        {
                            names.add(namesSet.getString("name"));
                        }

                        uniqueDefinitions.add(new UniqueDefinition(names));
                    }
                }
            }

            return uniqueDefinitions;
        }
    }

    private static void verifyColumns(final Connection                    connection,
                                      final String                        tableName,
                                      final Map<String, ColumnDefinition> requiredColumns,
                                      final Collection<UniqueDefinition>  uniques) throws SQLException
    {
    	// FORTIFY CWE - added verification of tableName upstream when required
        try(final Statement statement = connection.createStatement();
            final ResultSet tableInfo = statement.executeQuery(String.format("PRAGMA table_info(%s);", tableName)))
        {
            final Map<String, ColumnDefinition> columns = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);

            while(tableInfo.next())
            {
                final String columnName = tableInfo.getString("name");
                columns.put(columnName,
                            new ColumnDefinition(tableInfo.getString ("type"),
                                                 tableInfo.getBoolean("notnull"),
                                                 tableInfo.getBoolean("pk"),
                                                 uniques.stream().anyMatch(unique -> unique.equals(columnName)),
                                                 tableInfo.getString ("dflt_value")));
            }

            // Make sure the required fields exist in the table
            for(final Map.Entry<String, ColumnDefinition> column : requiredColumns.entrySet())
            {
                if(!columns.containsKey(column.getKey()))
                {
                    throw new RuntimeException(String.format("Required column: %s.%s is missing", tableName, column.getKey()));  // TODO this needs to be in the error string table
                }

                // We shouldn't be picky on table defaults as long as the content is correct
                final ColumnDefinition columnDefinition = columns.get(column.getKey());

                if(columnDefinition != null)
                {
                    if(!columnDefinition.equals(column.getValue()) ||
                       !checkExpressionEquivalence(connection,
                                                   columnDefinition.getDefaultValue(),
                                                   column.getValue().getDefaultValue()))    
                    {
                        throw new RuntimeException(String.format("Required column %s is defined as:\n%s\nbut should be:\n%s",
                                                                 column.getKey(),
                                                                 columnDefinition.toString(),
                                                                 column.getValue().toString()));
                    }
                }
            }
        }
    }

	/** 
	 * .equals() for ColumnDefinition skips comparing default values. 
	 * It's better to check for functional equivalence 
	 * rather than exact string equality. 
	 * This avoids issues with difference in white space 
	 * as well as other trivial annoyances.
	 * @param connection
	 * @param definition
	 * @param required
	 * @return
	 * @throws SQLException
	 */
    private static boolean checkExpressionEquivalence(final Connection connection,
                                                      final String     definition,
                                                      final String     required) throws SQLException
    {
        if((definition == null) || (required == null))
        {
            return (definition == null) && (required == null);
        }

        // Sometimes people use a synonym here and functional equivalence 
        // isn't possible because now is always changing
        if(required.replaceAll("\\s+","").equalsIgnoreCase("strftime('%Y-%m-%dT%H:%M:%fZ','now')")){
        	if (definition.replaceAll("\\s+","").equalsIgnoreCase("strftime('%Y-%m-%dT%H:%M:%fZ',current_timestamp)")){
        		return true;
        	}
        }
        
        final String definitionV = ValidateDescriptiveStringInput(definition);
        final String requiredV = ValidateDescriptiveStringInput(required);
        try(final Statement statement = connection.createStatement())
        {
            final String query = String.format("SELECT (%s) = (%s);",
            		definitionV,
            		requiredV);
            // FORTIFY CWE
            try(final ResultSet results = statement.executeQuery(query))
            {
                return results.next() && results.getBoolean(1);
            }
        }
        
    }

    private static void verifyForeignKeys(final Connection                connection,
                                          final String                    tableName,
                                          final Set<ForeignKeyDefinition> requiredForeignKeys) throws SQLException
    {
        try(final Statement statement = connection.createStatement())
        {
        	
        	// FORTIFY CWE - added check of tableName upstream if required
            try(final ResultSet fkInfo = statement.executeQuery(String.format("PRAGMA foreign_key_list(%s);", tableName)))
            {
                final List<ForeignKeyDefinition> foundForeignKeys = new LinkedList<>();

                while(fkInfo.next())
                {
                    foundForeignKeys.add(new ForeignKeyDefinition(fkInfo.getString("table"),
                                                                  fkInfo.getString("from"),
                                                                  fkInfo.getString("to")));
                }

                final Collection<ForeignKeyDefinition> missingKeys = new HashSet<>(requiredForeignKeys);
                missingKeys.removeAll(foundForeignKeys);

                final Collection<ForeignKeyDefinition> extraneousKeys = new HashSet<>(foundForeignKeys);
                extraneousKeys.removeAll(requiredForeignKeys);

                final StringBuilder error = new StringBuilder();

                if(!missingKeys.isEmpty())
                {
                    error.append(String.format("The table %s is missing the foreign key constraint(s): \n", tableName));
                    for(final ForeignKeyDefinition key : missingKeys)
                    {
                        error.append(String.format("%s.%s -> %s.%s\n",
                                                   tableName,
                                                   key.getFromColumnName(),
                                                   key.getReferenceTableName(),
                                                   key.getToColumnName()));
                    }
                }

                if(!extraneousKeys.isEmpty())
                {
                    error.append(String.format("The table %s has extraneous foreign key constraint(s): \n", tableName));
                    for(final ForeignKeyDefinition key : extraneousKeys)
                    {
                        error.append(String.format("%s.%s -> %s.%s\n",
                                                   tableName,
                                                   key.getFromColumnName(),
                                                   key.getReferenceTableName(),
                                                   key.getToColumnName()));
                    }
                }

                if(error.length() != 0)
                {
                    throw new RuntimeException(error.toString());     // TODO this needs to be in the error string table
                }
            }
            catch(final SQLException ignored)
            {
                // If a table has no foreign keys, executing the query
                // PRAGMA foreign_key_list(<table_name>) will throw an
                // exception complaining that result set is empty.
                // The issue has been posted about it here:
                // https://bitbucket.org/xerial/sqlite-jdbc/issue/162/
                // If the result set is empty (no foreign keys), there's no
                // work to be done.  Unfortunately .executeQuery() may throw an
                // SQLException for other reasons that may require some
                // attention.
            }
        }
    }

    private static void verifyGroupUniques(final String                       tableName,
                                           final Iterable<UniqueDefinition>   requiredGroupUniques,
                                           final Collection<UniqueDefinition> uniques)
    {
        for(final UniqueDefinition groupUnique : requiredGroupUniques)
        {
            if(!uniques.contains(groupUnique))
            {
                throw new RuntimeException(String.format("The table %s is missing the column group unique constraint: (%s)",
                                           tableName,
                                           String.join(", ", groupUnique.getColumnNames())));
            }
        }
    }
}
