/* The MIT License (MIT)
 *
 * Copyright (c) 2015 Reinventing Geospatial, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package org.opengis.cite.gpkg12;

import java.util.Collections;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * @author Luke Lambert
 *
 */
public class TableDefinition
{
    /**
     * Constructor
     *
     * @param name
     *            the name of the table
     * @param columns
     *            the names of the columns that pertain to the table name along
     *            with the Column Definition for each column
     */
    public TableDefinition(final String                        name,
                           final Map<String, ColumnDefinition> columns)
    {
        this(name, columns, Collections.emptySet(), Collections.emptySet());
    }

    /**
     * Constructor
     *
     * @param name
     *            the name of the table
     * @param columns
     *            the names of the columns that pertain to the table name along
     *            with the Column Definition for each column
     * @param foreignKeys
     *            the set of Foreign Key Constraints to the table
     */
    public TableDefinition(final String                        name,
                           final Map<String, ColumnDefinition> columns,
                           final Set<ForeignKeyDefinition>     foreignKeys)
    {
        this(name, columns, foreignKeys, Collections.emptySet());
    }


    /**
     * Constructor
     *
     * @param name
     *            the name of the table
     * @param columns
     *            the names of the columns that pertain to the table name along
     *            with the Column Definition for each column
     * @param foreignKeys
     *            the set of Foreign Key Constraints to the table
     * @param groupUniques
     *            the set of columns that must be unique (not necessarily unique
     *            individually, but unique as a set)
     */
    public TableDefinition(final String                        name,
                           final Map<String, ColumnDefinition> columns,
                           final Set<ForeignKeyDefinition>     foreignKeys,
                           final Set<UniqueDefinition>         groupUniques)
    {
        if(name == null || name.isEmpty())
        {
            throw new IllegalArgumentException("Table name may not be null or empty");
        }

        if(columns == null)
        {
            throw new IllegalArgumentException("Columns name may not be null");
        }

        if(foreignKeys == null)
        {
            throw new IllegalArgumentException("Foreign key collection may not be null");
        }

        if(groupUniques == null)
        {
            throw new IllegalArgumentException("Group uniques collection may not be null");
        }

        final Set<String> columnNames = columns.keySet();

        final Set<String> badForeignKeyFromColumns = foreignKeys.stream()
                                                                .map(foreignKey -> foreignKey.getFromColumnName())
                                                                .filter(foreignKeyFromColumnName -> !columnNames.contains(foreignKeyFromColumnName))
                                                                .collect(Collectors.toSet());

        if(badForeignKeyFromColumns.size() > 0)
        {
            throw new IllegalArgumentException(String.format("Foreign key definitions reference a the following 'from' columns that do not exist in this table: %s",
                                                             String.join(", ", badForeignKeyFromColumns)));
        }

        final Set<String> groupUniqueColumns = groupUniques.stream()
                                                            .collect(HashSet<String>::new,
                                                                     (set,  groupUnique) -> set.addAll(groupUnique.getColumnNames()),
                                                                     (set1, set2)        -> set1.addAll(set2));

        final Set<String> badGroupUniqueColumns = groupUniqueColumns.stream()
                                                            .filter(columnName -> !columnNames.contains(columnName))
                                                            .collect(Collectors.toSet());


        if(badGroupUniqueColumns.size() > 0)
        {
            throw new IllegalArgumentException(String.format("Group unique definitions reference the following columns that do not exist in this table: %s",
                                                             String.join(", ", badGroupUniqueColumns)));
        }

        this.name         = name;
        this.columns      = columns;
        this.foreignKeys  = foreignKeys;
        this.groupUniques = groupUniques;
    }

    /**
     * @return the table name
     */
    public String getName()
    {
        return this.name;
    }

    /**
     * @return the column definitions
     */
    public Map<String, ColumnDefinition> getColumns()
    {
        return this.columns;
    }

    /**
     * @return the foreign key definitions
     */
    public Set<ForeignKeyDefinition> getForeignKeys()
    {
        return this.foreignKeys;
    }

    /**
     * @return the groupUniques
     */
    protected Set<UniqueDefinition> getGroupUniques()
    {
        return this.groupUniques;
    }

    private final String                        name;
    private final Map<String, ColumnDefinition> columns;
    private final Set<ForeignKeyDefinition>     foreignKeys;
    private final Set<UniqueDefinition>         groupUniques;
}
