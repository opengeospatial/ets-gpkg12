package org.opengis.cite.gpkg12.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Provides database utility methods
 *
 * @author Luke Lambert
 */
public final class DatabaseUtility
{
    /**
     * DatabaseUtility is not to be instantiated
     */
    private DatabaseUtility()
    {

    }

    /**
     * @param connection
     *            the connection to the database
     * @param name
     *            the name of the table
     * @return true if the table or view exists in the database; otherwise
     *         returns false
     * @throws SQLException
     *             throws if unable to connect to the database or other various
     *             SQLExceptions
     */
    public static boolean doesTableOrViewExist(final Connection connection, final String name) throws SQLException
    {
        try(final PreparedStatement preparedStatement = connection.prepareStatement("SELECT COUNT(*) FROM sqlite_master WHERE (type = 'table' OR type = 'view') AND name = ? LIMIT 1;"))
        {
            preparedStatement.setString(1, name);

            try(final ResultSet resultSet = preparedStatement.executeQuery())
            {
                return resultSet.getInt(1) > 0;
            }
        }
    }
}
