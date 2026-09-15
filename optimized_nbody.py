"""
Optimized N-Body Simulation
This version avoids object-oriented overhead in the inner loop by flattening
coordinates and velocities into 1D lists, and inlining distance calculations.
"""

from math import sqrt
from itertools import combinations
import sys

# Constants
PI = 3.14159265358979323
SOLAR_MASS = 4 * PI * PI
DAYS_PER_YEAR = 365.24

def advance(dt, n, m, px, py, pz, vx, vy, vz):
    """
    Advance the system by time dt.
    Inlining the pair calculations and using flat lists avoids object 
    dereferencing in the inner loop (a major bottleneck in the baseline).
    """
    for _ in range(10): # Running a few iterations for benchmark representation
        # Calculate forces
        for i in range(n):
            for j in range(i + 1, n):
                dx = px[i] - px[j]
                dy = py[i] - py[j]
                dz = pz[i] - pz[j]
                
                # Math optimization: avoid ** 2
                distance = sqrt(dx*dx + dy*dy + dz*dz)
                mag = dt / (distance * distance * distance)
                
                # Mass integration
                vx[i] -= dx * m[j] * mag
                vy[i] -= dy * m[j] * mag
                vz[i] -= dz * m[j] * mag
                
                vx[j] += dx * m[i] * mag
                vy[j] += dy * m[i] * mag
                vz[j] += dz * m[i] * mag
        
        # Advance positions
        for i in range(n):
            px[i] += dt * vx[i]
            py[i] += dt * vy[i]
            pz[i] += dt * vz[i]

def main(n_steps=1000):
    # System initialization (Sun + Jovian planets)
    m = [1.0, 9.54791938424326609e-04, 2.85885980666130812e-04, 4.36624404335156298e-05, 5.15138902046611451e-05]
    px = [0.0, 4.84143144246472090e+00, 8.34336671824457987e+00, 1.28943695621391310e+01, 1.53796971148509165e+01]
    py = [0.0, -1.16032004402742839e+00, 4.12479856412430479e+00, -1.51111514016986312e+01, -2.59193146099879641e+01]
    pz = [0.0, -1.03622044471123109e-01, -4.03523417114321381e-01, -2.23307578892655734e-01, 1.79258772950371181e-01]
    vx = [0.0, 1.66007664274403694e-03 * DAYS_PER_YEAR, -2.76742510726862411e-03 * DAYS_PER_YEAR, 2.96460137564761618e-03 * DAYS_PER_YEAR, 2.68067772490389322e-03 * DAYS_PER_YEAR]
    vy = [0.0, 7.69901118419740425e-03 * DAYS_PER_YEAR, 4.99852801234917238e-03 * DAYS_PER_YEAR, 2.37847173959480950e-03 * DAYS_PER_YEAR, 1.62824170038242295e-03 * DAYS_PER_YEAR]
    vz = [0.0, -6.90460016972063023e-05 * DAYS_PER_YEAR, 2.30417297573763929e-05 * DAYS_PER_YEAR, -2.96589568540237556e-05 * DAYS_PER_YEAR, -9.51592254519715870e-05 * DAYS_PER_YEAR]
    
    # Scale masses by solar mass
    m = [mass * SOLAR_MASS for mass in m]
    
    n = len(m)
    for _ in range(n_steps):
        advance(0.01, n, m, px, py, pz, vx, vy, vz)
        
if __name__ == '__main__':
    main(1000)
