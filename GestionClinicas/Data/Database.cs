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

        public static SqlConnection GetConnection()
        {
            if (_connection == null)
            {
                string connStr = ConfigurationManager.ConnectionStrings["SqlConn"].ConnectionString;
                _connection = new SqlConnection(connStr);
            }
            return _connection;
        }
    }
}
