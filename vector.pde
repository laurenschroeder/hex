

class Vector {
    float x,y;
    Vector(Vector copy) {
        x = copy.x;
        y = copy.y;
    }

    Vector(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
    Vector get() {
      return new Vector(x,y);
    }
    
    Vector to(Vector that) {
        return new Vector(that.x-x, that.y-y);
    }

    Vector sub(Vector that) {
        return new Vector(x-that.x, y-that.y);
    }

    Vector add(Vector that) {
        return new Vector(x+that.x, y+that.y);
    }

    Vector mul(float s) {
        return new Vector(s*x, s*y);
    }

    float magnitude() {
        return sqrt(sq(x) + sq(y));
    }

    Vector rotate(float angle) {
        return new Vector(
            cos(angle) * x - sin(angle) * y,
            sin(angle) * x + cos(angle) * y
        );
    }
    
    public int hashCode() {
      return Float.hashCode(x) ^ Float.hashCode(y);
    }
    
    public boolean equals(Object o) {
      if (o instanceof Vector) {
        Vector that = (Vector)o;
        return x == that.x && y == that.y; 
      } else {
        return false;
      }
    }
}

float dist(Vector p0, Vector p1) {
    return sqrt(sqdist(p0,p1));

}

float sqdist(Vector p0, Vector p1) {
    return sq(p0.x-p1.x) + sq(p0.y-p1.y);
}

Vector fromRadialCoords(Vector c, float r, float theta) {
    return new Vector(
        c.x + r * cos(theta),
        c.y + r * sin(theta)
    );
}
