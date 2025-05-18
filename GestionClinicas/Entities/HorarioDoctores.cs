using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GestionClinicas.Entities
{
    public class HorarioDoctores
    {
        public int HorarioID { get; set; }
        public int DoctorID { get; set; }
        public int Dia { get; set; } // 1: Lunes, 2: Martes, ..., 7: Domingo
        public TimeSpan HoraInicio { get; set; }
        public TimeSpan HoraFin { get; set; }
    }
}
