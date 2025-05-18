using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GestionClinicas.Entities
{
    public class Doctor
    {
        public int DoctorID { get; set; }
        public string Nombre { get; set; }
        public string Especializacion { get; set; }
        public string Telefono { get; set; }
    }
}
