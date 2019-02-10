
class Circle {
    Vector center;
    float radius;
    
    Circle(Vector center, float radius) {
        this.center = center;
        this.radius = radius;
    }

    boolean overlap(Circle that) {
        return sqdist(center, that.center) <= sq(radius + that.radius);
    }
}


Circle boundingCircle(Poly poly) {
    Vector center = centroid(poly.points);
    float radius = 0;
    for (Vector p : poly.points) {
        radius = max(radius, dist(center, p));
    }

    return new Circle(center, radius);
}

Vector centroid(List<Vector> pts) {
    Vector result = new Vector(0,0);
    for (Vector p : pts) {
        result.x += p.x;
        result.y += p.y;
    }
    return result.mul(1.0f / pts.size());
}
