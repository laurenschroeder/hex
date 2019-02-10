import java.util.List;
import java.util.Map;

// The important parameters.
int NUM_FACES = 20;
float SHRINK = 0.52;
float JITTER = 5;

// Globals object.
class App {
    Mesh mesh;
    List<Integer> distFromRoot;
    List<Integer> growthOrder;
    List<Circle>  faceBounds;
}

App app = new App();

void growth() {

    Mesh m = new Mesh();
    app.mesh = m;
    m.addPolygon(regularPentagon(new Vector(width/2,height/2), width/8, 0));

    // Per face data.
    app.distFromRoot = new ArrayList<Integer>();
    app.faceBounds = new ArrayList<Circle>();

    int n = 0;
    app.distFromRoot.add(0);
    app.faceBounds.add(boundingCircle(m.getFace(n)));

    for (int i = 0; i < NUM_FACES; i++) {
        for (HalfEdge edge : m.perimeterHalfEdges()) {
            Poly poly = regularPentagonWithEdge(edge, SHRINK, JITTER);

            Circle bc = boundingCircle(poly);
            bc.radius *= 0.9;

            if (countOverlaps(bc) < 2) {
                n += 1;
                m.addPolygon(poly);
                app.distFromRoot.add(1 + app.distFromRoot.get(edge.faceId));
                app.faceBounds.add(boundingCircle(m.getFace(n)));
                break;
            }
        }
    }
}

void draw() {
    background(250);
    ellipseMode(RADIUS);

    stroke(255);
    strokeWeight(2);

    for (int fi = 0; fi < app.mesh.numFaces(); fi++) {
        Poly p = app.mesh.getFace(fi);
        int d = app.distFromRoot.get(fi);
        fill(max(0, 220 - 20 * d), 240, max(0, 240 - 5 * d));
        polygon(p);
    }
}

void setup() {
    size(640,480);
    pixelDensity(displayDensity());
    dataSetup();
}

Poly regularPentagon(Vector center, float radius, float angle) {
    Poly poly = new Poly();
    for (int i = 0; i < 5; i++) {
        float theta = i * TWO_PI / 5.0 + angle;
        poly.add(fromRadialCoords(center, radius, theta));
    }
    return poly;
}

Poly regularPentagonWithEdge(HalfEdge edge) {
    return regularPentagonWithEdge(edge, 1.0, 0.0);
}

Poly regularPentagonWithEdge(HalfEdge edge, float scaling, float jitter) {
    Vector start = edge.startVertex();]]]]]]]]]]]]]]
    Vector end   = edge.endVertex();
    Vector midpoint = start.add(end).mul(0.5f);
    Vector offset  = end.to(start);
    Poly poly = new Poly();
    poly.add(end.get());
    poly.add(start.get());

    Vector cur = start;
    for (int i = 0; i < 3; i++) {
        offset = offset.rotate(TWO_PI / 5.0);
        cur = cur.add(offset);
        Vector vertex = midpoint.to(cur).mul(scaling).add(midpoint).add(new Vector(random(-jitter, jitter), random(-jitter, jitter)));
        poly.add(vertex);
    }
    return poly;
}

int countOverlaps(Circle c) {
    int overlaps = 0;
    for(int faceId = 0; faceId < app.mesh.numFaces(); faceId++) {
        if (app.faceBounds.get(faceId).overlap(c)) overlaps++;
    }
    return overlaps;
}


void dataSetup() {
    growth();
}

void keyPressed() {
    if (key == ' ') {
        dataSetup();
    }
}

void polygon(Poly pts) {
    beginShape();
    for (Vector pt : pts.points) {
        vertex(pt.x, pt.y);
    }
    endShape(CLOSE);
}

void circle(Circle c) {
    ellipse(c.center.x, c.center.y, c.radius, c.radius);
}
