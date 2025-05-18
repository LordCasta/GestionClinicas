using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data.SqlClient;

namespace GestionClinicas.Data
{
    public class Database
    {
        private static SqlConnection _connection;
        private static readonly object _lock = new object();

        public static SqlConnection GetConnection()
        {
            if (_connection == null || _connection.State == System.Data.ConnectionState.Closed || _connection.State == System.Data.ConnectionState.Broken)
            {
                lock (_lock)
                {
                    if (_connection == null || _connection.State == System.Data.ConnectionState.Closed || _connection.State == System.Data.ConnectionState.Broken)
                    {
                        string connStr = ConfigurationManager.ConnectionStrings["SqlConn"].ConnectionString;
                        _connection = new SqlConnection(connStr);
                        _connection.Open();
                    }
                }
            }

            return _connection;
        }
    }
}
