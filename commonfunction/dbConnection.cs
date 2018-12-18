using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;

namespace commonfunction
{
    public class dbConnection
    {

        SqlConnection sqlCon;
        SqlCommand sqlCmd;
        SqlDataAdapter sqlDA;
        SqlTransaction sqlTrans;
        public dbConnection()
        {
            sqlCon = new SqlConnection(ConfigurationManager.AppSettings["DB_CONNECT"]);
        }
        public DataTable SelectQuery(string strQuery)
        {
            try
            {
                DataTable dt = new DataTable();
                sqlCmd = new SqlCommand(strQuery, sqlCon);
                sqlCmd.CommandType = CommandType.Text;
                sqlCon.Open();
                sqlCmd.ExecuteNonQuery();
                sqlDA = new SqlDataAdapter(sqlCmd);
                sqlDA.Fill(dt);
                return dt;
            }
            catch (SqlException exc)
            {
                return null;
            }
            finally
            {
                sqlCon.Close();
            }
        }

        public string SelectScalar(string strQuery)
        {
            try
            {
                DataTable dt = new DataTable();
                sqlCmd = new SqlCommand(strQuery, sqlCon);
                sqlCmd.CommandType = CommandType.Text;
                sqlCon.Open();
                int id = Convert.ToInt32(sqlCmd.ExecuteScalar());
                return Convert.ToString(id);

            }
            catch (SqlException exc)
            {
                return null;
            }
            finally
            {
                sqlCon.Close();
            }
        }



        public DataTable SelectSP(string strSP, params IDataParameter[] commandParameters)
        {
            try
            {
                DataTable dt = new DataTable();
                sqlCmd = new SqlCommand(strSP, sqlCon);
                sqlCmd.CommandType = CommandType.StoredProcedure;
                foreach (SqlParameter par in commandParameters)
                    sqlCmd.Parameters.Add(par);
                sqlCon.Open();
                sqlCmd.ExecuteNonQuery();
                sqlDA = new SqlDataAdapter(sqlCmd);
                sqlDA.Fill(dt);
                return dt;
            }
            catch (SqlException exc)
            {
                return null;
            }
            finally
            {
                sqlCmd.Parameters.Clear();
                sqlCon.Close();
            }
        }
        public bool ExecuteQuery(string strQuery)
        {
            try
            {
                sqlCmd = new SqlCommand(strQuery, sqlCon);
                sqlCmd.CommandType = CommandType.Text;
                sqlCon.Open();
                sqlCmd.ExecuteNonQuery();
                return true;
            }
            catch (SqlException exc)
            {
                //throw exc;
                return false;
            }
            finally
            {
                sqlCmd.Parameters.Clear();
                sqlCon.Close();
            }
        }
        public bool ExecuteSP(string strSP, params IDataParameter[] commandParameters)
        {
            try
            {
                sqlCmd = new SqlCommand(strSP, sqlCon);
                sqlCmd.CommandType = CommandType.StoredProcedure;
                foreach (SqlParameter par in commandParameters)
                    sqlCmd.Parameters.Add(par);
                sqlCon.Open();
                sqlCmd.ExecuteNonQuery();
                return true;
            }
            catch (SqlException exc)
            {
                return false;
            }
            finally
            {
                sqlCmd.Parameters.Clear();
                sqlCon.Close();
            }
        }
        public void OpenConnection()
        {
            try
            {
                sqlCon.Open();
            }
            catch (SqlException exc)
            {
                throw new Exception(exc.Message + "OpenConnection()sqlexception");
            }
            catch (Exception exp)
            {
                throw new Exception(exp.Message + "OpenConnection()");
            }
        }
        public void CloseConnection()
        {
            try
            {
                sqlCon.Close();
            }
            catch (SqlException exc)
            {
                throw new Exception(exc.StackTrace + ". DB Close Connection Problem");
            }
        }
        public void BeginTransaction()
        {
            try
            {
                sqlTrans = sqlCon.BeginTransaction();
            }
            catch (SqlException exc)
            {
                throw new Exception(exc.Message);
            }
        }
        public void CommitTransaction()
        {
            try
            {
                sqlTrans.Commit();
            }
            catch (SqlException exc)
            {
                throw new Exception(exc.Message);
            }
        }
        public void RollBackTransaction()
        {
            try
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Rollback();
                }
            }
            catch (SqlException exc)
            {
                throw new Exception(exc.Message);
            }
        }

    }
}
