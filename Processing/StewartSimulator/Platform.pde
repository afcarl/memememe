class Platform {
  private PVector translation, rotation, initialHeight;
  private PVector[] baseJoint, phoneJoint, q, l, A;
  private float[] alpha, beta;
  private float baseRadius, phoneRadius, hornLength, legLength;

  public Platform(float s) {
    translation = new PVector();
    initialHeight = new PVector(0, 0, 1.625*s);
    rotation = new PVector();
    baseJoint = new PVector[6];
    phoneJoint = new PVector[6];
    alpha = new float[6];
    beta = new float[6];
    q = new PVector[6];
    l = new PVector[6];
    A = new PVector[6];
    baseRadius = s;
    phoneRadius = 0.2*s;
    hornLength = 0.375*s;
    legLength = 1.875*s;

    for (int i=0; i<6; i++) {
      float mx = baseRadius*cos((PI/3*i)+((i%2==1)?PI/12:-PI/12));
      float my = baseRadius*sin((PI/3*i)+((i%2==1)?PI/12:-PI/12));
      baseJoint[i] = new PVector(mx, my, 0);
      // magik !!
      beta[i] = ((i%2==1)?((i-1)*(-TWO_PI/3)):(i*(-TWO_PI/3)+(PI/3)));
    }

    for (int i=0; i<6; i++) {
      float mx = phoneRadius*cos((PI/3*i)+((i%2==0)?PI/12:-PI/12));
      float my = phoneRadius*sin((PI/3*i)+((i%2==0)?PI/12:-PI/12));
      phoneJoint[i] = new PVector(mx, my, 0);
      q[i] = new PVector(0, 0, 0);
      l[i] = new PVector(0, 0, 0);
      A[i] = new PVector(0, 0, 0);
    }
    calcQ();
  }

  public void applyTranslationAndRotation(PVector t, PVector r) {
    rotation.set(r);
    translation.set(t);
    calcQ();
    calcAlpha();
  }

  private void calcQ() {
    for (int i=0; i<6; i++) {
      // rotation
      q[i].x = cos(rotation.z)*cos(rotation.y)*phoneJoint[i].x + 
        (-sin(rotation.z)*cos(rotation.x)+cos(rotation.z)*sin(rotation.y)*sin(rotation.x))*phoneJoint[i].y + 
        (sin(rotation.z)*sin(rotation.x)+cos(rotation.z)*sin(rotation.y)*cos(rotation.x))*phoneJoint[i].z;

      q[i].y = sin(rotation.z)*cos(rotation.y)*phoneJoint[i].x + 
        (cos(rotation.z)*cos(rotation.x)+sin(rotation.z)*sin(rotation.y)*sin(rotation.x))*phoneJoint[i].y + 
        (-cos(rotation.z)*sin(rotation.x)+sin(rotation.z)*sin(rotation.y)*cos(rotation.x))*phoneJoint[i].z;

      q[i].z = -sin(rotation.y)*phoneJoint[i].x + 
        cos(rotation.y)*sin(rotation.x)*phoneJoint[i].y + 
        cos(rotation.y)*cos(rotation.x)*phoneJoint[i].z;

      // translation
      q[i].add(PVector.add(translation, initialHeight));
      l[i] = PVector.sub(q[i], baseJoint[i]);
    }
  }

  private void calcAlpha() {
    for (int i=0; i<6; i++) {
      float L = l[i].magSq()-(legLength*legLength)+(hornLength*hornLength);
      float M = 2*hornLength*(phoneJoint[i].z-baseJoint[i].z);
      float N = 2*hornLength*(cos(beta[i])*(phoneJoint[i].x-baseJoint[i].x) + sin(beta[i])*(phoneJoint[i].y-baseJoint[i].y));
      alpha[i] = asin(L/sqrt(M*M+N*N)) - atan2(N, M);

      A[i].set(hornLength*cos(alpha[i])*cos(beta[i]) + baseJoint[i].x,
      hornLength*cos(alpha[i])*sin(beta[i]) + baseJoint[i].y,
      hornLength*sin(alpha[i]) + baseJoint[i].z);

      float xpxb = (phoneJoint[i].x-baseJoint[i].x);
      float ypyb = (phoneJoint[i].y-baseJoint[i].y);
      float h0 = sqrt((legLength*legLength)+(hornLength*hornLength)-(xpxb*xpxb)-(ypyb*ypyb)) - phoneJoint[i].z;

      float L0 = 2*hornLength*hornLength;
      float M0 = 2*hornLength*(h0+phoneJoint[i].z);
      float a0 = asin(L0/sqrt(M0*M0+N*N)) - atan2(N, M0);

      //println(i+":"+alpha[i]+"  h0:"+h0+"  a0:"+a0);
    }
  }

  public void draw() {
    // draw Base
    noStroke();
    fill(128);
    ellipse(0, 0, 2*baseRadius, 2*baseRadius);
    for (int i=0; i<6; i++) {
      pushMatrix();
      translate(baseJoint[i].x, baseJoint[i].y, baseJoint[i].z);
      noStroke();
      fill(0);
      ellipse(0, 0, 5, 5);

      pushMatrix();
      rotateZ(beta[i]);
      stroke(245);
      line(0, 0, hornLength, 0);
      popMatrix();

      popMatrix();

      stroke(255, 0, 0);
      line(baseJoint[i].x, baseJoint[i].y, baseJoint[i].z, A[i].x, A[i].y, A[i].z);

      PVector rod = PVector.sub(q[i], A[i]);
      rod.setMag(legLength);
      rod.add(A[i]);

      stroke(255, 0, 255);
      line(A[i].x, A[i].y, A[i].z, rod.x, rod.y, rod.z);
    }

    // draw phone jointss and rods
    for (int i=0; i<6; i++) {
      pushMatrix();
      translate(q[i].x, q[i].y, q[i].z);
      noStroke();
      fill(0);
      ellipse(0, 0, 5, 5);
      popMatrix();

      stroke(100);
      strokeWeight(1);
      line(baseJoint[i].x, baseJoint[i].y, baseJoint[i].z, q[i].x, q[i].y, q[i].z);
    }

    // sanity check
    pushMatrix();
    translate(initialHeight.x, initialHeight.y, initialHeight.z);
    translate(translation.x, translation.y, translation.z);
    rotateZ(rotation.z);
    rotateY(rotation.y);
    rotateX(rotation.x);
    stroke(245);
    noFill();
    ellipse(0, 0, 2*phoneRadius, 2*phoneRadius);
    popMatrix();
  }
}
