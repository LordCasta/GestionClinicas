using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GestionClinicas.Entities
{
    public class Pagos
    {
        public int PagoID { get; set; }
        public int TratamiendoID { get; set; }
        public decimal Monto { get; set; }
        public DateTime FechaPago { get; set; }
        public string MetodoPago { get; set; } // Efectivo, Tarjeta, Transferencia
    }
}
