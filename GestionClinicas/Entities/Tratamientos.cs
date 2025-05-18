using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GestionClinicas.Entities
{
    public class Tratamientos
    {
        public int TratamientoID { get; set; }
        public int PacienteID { get; set; }
        public string TipoTratamiento { get; set; } 
        public DateTime FechaInicio { get; set; }
        public int Duracion { get; set; } // en días
        public decimal CostoTotal { get; set; }
        public decimal SaldoPendiente { get; set; }
    }
}
