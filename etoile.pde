ArrayList<particule> Particules=new ArrayList<particule>();
PVector origine=new PVector(0, 0);
float myG=0.0000000000008;
float gamma=-80;
int max_particule=40;
int max_subparticule=7;
int max_sub_age=30;
float max_radius=20;
int max_age=5000;
float[] distribution = new float[18];
float charge=2000000000;
float Vmax=5;
float dliaison_max=150;
float E_max=100*pow(max_radius, 3)*4/3*PI/5;
int framedelay=10;
boolean debug=false;
//PImage bg;

void setup() {
  background(0);
  //bg = loadImage("fond.jpg");
  //max_particule=int (max_particule/(2560*1440)*width*height);
  while (Particules.size()<max_particule) {
    Particules.add(new particule(0, max_age, max_radius, random(-1, 1), random(-1, 1), -1, origine));
  }
}

void settings() {
  
  fullScreen();
  //noLoop();
  //size(1920,1080);
}

void draw() {
  //background(bg);
  for (int i=0; i<Particules.size(); i++) {
    float radius=Particules.get(i).getRadius();
    for (int j = 0; j < distribution.length; j++) {
      distribution[j] = int(randomGaussian() * radius*3);
    }
    if (Particules.get(i).vitesse.mag()>Vmax) {
      if (random(0, 130)>1) {
        float Energie_cinetique=0.5*Particules.get(i).masse*(pow(Particules.get(i).vitesse.mag(), 2)-pow(Vmax, 2));
        Particules.get(i).subparticulescreate(2, Energie_cinetique, Particules.get(i).position);
        Particules.get(i).subparticulesdraw();

        Particules.get(i).vitesse.normalize();
        Particules.get(i).vitesse.mult(Vmax);
      } else {
        //Particules.get(i).subparticulesdraw();
        Particules.get(i).setAge(max_age-1);
        Particules.get(i).look_older();
      }
    }
    int age=Particules.get(i).getAge();
    if (age<max_age) {
      pushMatrix();
      translate(Particules.get(i).position.x, Particules.get(i).position.y);
      for (int k = 0; k < distribution.length; k++) {
        rotate(TWO_PI/distribution.length+random(-0.3, 0.3));
        stroke(255, 0, 0, 35+age%20);
        strokeWeight(1);
        float dist = abs(distribution[k]);
        line(0, 0, dist, 0);
        point(dist/2, 0);
      }
      noStroke();
      fill(255, 0, 0, 10+age%30/2);
      //stroke(255, 0, 0, 40+age%10);
      //noFill();
      ellipse(0, 0, random(radius, 2*radius), random(radius, 2*radius));
      popMatrix();
      Particules.get(i).subparticulesmove();
      Particules.get(i).subparticulesdraw();
    } else if (age==max_age) {
      Particules.get(i).subparticulescreate(max_subparticule, Particules.get(i).energie, Particules.get(i).position);
    } else {
      Particules.get(i).subparticulesdraw();
      Particules.get(i).subparticulesmove();
    }
    //stroke(255);
    //Particules.get(i).vitesse.limit(Vmax);
    if (debug) {
      float value;
      float x=Particules.get(i).position.x;
      float y=Particules.get(i).position.y;
      PVector acceleration=Particules.get(i).position.copy();
      acceleration.add(Particules.get(i).acceleration);
      fill(0, 102, 153);
      text(i, x, y);
      text(Particules.get(i).radius, x, y+13);
      text(Particules.get(i).masse, x, y+26);
      text(Particules.get(i).energie, x, y+39);
      value=Particules.get(i).acceleration.mag();
      value=value*1000;
      print("value : ", value, "\n");
      text(value, x+1000*acceleration.x, y+1000*acceleration.y);
      stroke(0, 255, 0, 100);
      line(Particules.get(i).position.x, Particules.get(i).position.y, Particules.get(i).position.x+Particules.get(i).acceleration.x*1000, Particules.get(i).position.y+Particules.get(i).acceleration.y*1000);
      noFill();
      ellipse(Particules.get(i).position.x, Particules.get(i).position.y, Particules.get(i).getRadius(), Particules.get(i).getRadius());
    }
    Particules.get(i).look_older();
    //text(Particules.get(i).vitesse.mag(), Particules.get(i).position.x, Particules.get(i).position.y); 
    if (Particules.get(i).getAge()>max_age+max_sub_age) {
      Particules.remove(i);
      Particules.add(new particule(0, max_age, max_radius, random(-1, 1), random(-1, 1), -1, origine));
    }
  }
  //while (Particules.size()<max_particule) {
  //  Particules.add(new particule(0, max_age, max_radius, random(-1, 1), random(-1, 1), -1,origine));
  //}    
  stroke(0, 30);
  fill(0, 30);
  rect(0, 0, width, height);
  while (Particules.size()<max_particule) {
    Particules.add(new particule(0, max_age, max_radius, random(-1, 1), random(-1, 1), -1, origine));
  }    
  delay(framedelay);
  update_physics(Particules);
  update_liaison(Particules);
  update_gravitationnelle(Particules);
  update_electromagnetique(Particules);
  visual_liaison(Particules);
}


void update_physics(ArrayList<particule> Particules) {
  for (int i=0; i<Particules.size(); i++) {
    Particules.get(i).acceleration.set(0, 0);
  }
}

void update_gravitationnelle(ArrayList<particule> Particules) {
  PVector F=new PVector();
  PVector Fi=new PVector();
  PVector Fj=new PVector();

  float Fvalue;
  for (int i=0; i<Particules.size(); i++) {
    for (int j=i+1; j<Particules.size(); j++) {
      if (Particules.get(i).masse!=0 && Particules.get(j).masse!=0) {
        float d=PVector.dist(Particules.get(i).position, Particules.get(j).position);
        d=d/10;
        Fvalue=myG*Particules.get(i).masse*Particules.get(j).masse/(d*d);
        F=Particules.get(j).position.copy();
        F.sub(Particules.get(i).position);
        F.normalize();
        F.mult(Fvalue);
        Fi=F.copy();
        Fj=F.copy();
        //print ("F :",F,"\n");
        //stroke(255,0,0);
        //strokeWeight(3);
        Particules.get(i).vitesse.add(Fi);
        Particules.get(i).acceleration.add(Fi);
        //line(Particules.get(i).position.x,Particules.get(i).position.y,Particules.get(i).position.x+1000000*F.x,Particules.get(i).position.y+1000000*F.y);
        //line(Particules.get(j).position.x,Particules.get(j).position.y,Particules.get(j).position.x-1000000*F.x,Particules.get(j).position.y-1000000*F.y);
        Particules.get(j).vitesse.sub(Fj);
        Particules.get(j).acceleration.sub(Fj);
        if (str(Fi.x)=="NaN" ||str(Fj.x)=="NaN" ) {
          Particules.get(i).setAge(max_age-1);
          Particules.get(i).look_older();
          Particules.get(j).setAge(max_age-1);
          Particules.get(j).look_older();
        }
      }
    }
  }
}

void update_electromagnetique(ArrayList<particule> Particules) {
  PVector F=new PVector();
  PVector Fi=new PVector();
  PVector Fj=new PVector();
  float Fvalue;
  for (int i=0; i<Particules.size(); i++) {
    for (int j=i+1; j<Particules.size(); j++) {
      if (Particules.get(i).masse!=0 && Particules.get(j).masse!=0) {
        float d=PVector.dist(Particules.get(i).position, Particules.get(j).position);
        Fvalue=charge/(d*d*d);
        F=Particules.get(j).position.copy();
        F.sub(Particules.get(i).position);
        F.normalize();
        F.mult(Fvalue);
        Fi=F.copy();
        Fj=F.copy();
        //print("Fi : ", Fi, "\n");
        //print("Fj : ", Fj, "\n");
        Fi=Fi.div(Particules.get(i).masse);
        Fj=Fj.div(Particules.get(j).masse);
        //stroke(128);
        //strokeWeight(3);
        Particules.get(i).vitesse.sub(Fi);
        Particules.get(i).acceleration.sub(Fi);
        Particules.get(j).vitesse.add(Fj);
        Particules.get(j).acceleration.add(Fj);
        //line(Particules.get(i).position.x,Particules.get(i).position.y,Particules.get(i).position.x+1000000*F.x,Particules.get(i).position.y+1000000*F.y);
        //line(Particules.get(j).position.x,Particules.get(j).position.y,Particules.get(j).position.x-1000000*F.x,Particules.get(j).position.y-1000000*F.y);
        if (str(Particules.get(i).vitesse.x)=="NaN" ||str(Particules.get(i).vitesse.x)=="NaN" ) {
          Particules.get(i).setAge(max_age-1);
          Particules.get(i).look_older();
          Particules.get(j).setAge(max_age-1);
          Particules.get(j).look_older();
        }
      }
    }
  }
}
void visual_liaison(ArrayList<particule> Particules) {
  PVector F=new PVector();
  float dlimit;
  color from[]={color(255, 0, 0), color(255, 117, 0), color(255, 255, 0), color(127, 255, 0), color(0, 255, 0), color(0, 178, 255), color(28, 0, 255)};
  color to[]={color(255, 117, 0), color(255, 255, 0), color(127, 255, 0), color(0, 255, 0), color(0, 178, 255), color(28, 0, 255), color(71, 0, 143)};
  for (int i=0; i<Particules.size(); i++) {
    for (int j=i+1; j<Particules.size(); j++) {
      dlimit=4*(Particules.get(i).getRadius()+Particules.get(j).getRadius());
      float d=PVector.dist(Particules.get(i).position, Particules.get(j).position);
      if (d<dlimit && Particules.get(i).masse!=0 && Particules.get(j).masse!=0) {
        int color_idx=int(d*7/dlimit);
        color_idx=min(6, color_idx);
        ArrayList<PVector> temppart=new ArrayList<PVector>();
        int nbpoint=int(random(3, 16));
        F=Particules.get(j).position.copy();
        F.sub(Particules.get(i).position);
        //F.normalize();
        //stroke(0,128,0);
        //line(Particules.get(i).position.x,Particules.get(i).position.y,Particules.get(i).position.x+F.x,Particules.get(i).position.y+F.y);

        for (int k=0; k<nbpoint; k++) {
          PVector tempF=new PVector();
          tempF=F.copy();
          tempF.mult((float(k)+1)/(nbpoint+1));
          temppart.add(new PVector(0, 0));
          temppart.get(k).add(Particules.get(i).position);
          temppart.get(k).add(tempF);
          float alea=25*d/dlimit;
          temppart.get(k).x=temppart.get(k).x+random(-alea, alea);
          temppart.get(k).y=temppart.get(k).y+random(-alea, alea);
        }
        stroke(lerpColor(from[6-color_idx], to[6-color_idx], (1-d%14/14)*100), (1-d/dlimit)*100);
        strokeWeight(1);
        line(Particules.get(i).position.x, Particules.get(i).position.y, temppart.get(0).x, temppart.get(0).y);
        for (int l=1; l<nbpoint-1; l++) {
          line(temppart.get(l-1).x, temppart.get(l-1).y, temppart.get(l).x, temppart.get(l).y);
        }
        line(temppart.get(nbpoint-1).x, temppart.get(nbpoint-1).y, Particules.get(j).position.x, Particules.get(j).position.y);
      }
    }
  }
}

void update_liaison(ArrayList<particule> Particules) {
  //PVector F=new PVector();
  PVector Fi=new PVector();
  PVector Fj=new PVector();
  PVector F2i=new PVector();
  PVector F2j=new PVector();
  PVector Fij=new PVector();
  float dlimit;
  float Fivalue;
  float Fjvalue;
  float F2ivalue;
  float F2jvalue;
  for (int i=0; i<Particules.size(); i++) {
    for (int j=i+1; j<Particules.size(); j++) {
      dlimit=6*(Particules.get(i).getRadius()+Particules.get(j).getRadius());
      float d=PVector.dist(Particules.get(i).position, Particules.get(j).position);
      if (d<dlimit && Particules.get(i).masse!=0 && Particules.get(j).masse!=0) {
        //Fivalue=gamma*(Particules.get(i).getRadius()+Particules.get(j).getRadius())*((d/dlimit)+1/(d-dlimit))*Particules.get(i).vitesse.mag();
        //Fjvalue=gamma*(Particules.get(i).getRadius()+Particules.get(j).getRadius())*((d/(dlimit)+1/(d-dlimit))*Particules.get(j).vitesse.mag();
        //Fivalue=gamma*log(d/dlimit)*Particules.get(i).vitesse.mag();
        //Fjvalue=gamma*log(d/dlimit)*Particules.get(j).vitesse.mag();
        Fivalue=gamma*pow(2*(d-dlimit/2)/dlimit, 1)*Particules.get(i).vitesse.mag();
        Fjvalue=gamma*pow(2*(d-dlimit/2)/dlimit, 1)*Particules.get(j).vitesse.mag();
        Fi=Particules.get(i).vitesse.copy();
        Fi.normalize();
        Fi=Fi.mult((Particules.get(i).vitesse.mag()-Fivalue)/Particules.get(i).masse);
        Fj=Particules.get(j).vitesse.copy();
        Fj.normalize();
        Fj=Fj.mult((Particules.get(j).vitesse.mag()-Fjvalue)/Particules.get(j).masse);    
        F2ivalue=pow(1*(d-dlimit/2)/dlimit, 1)*d*gamma/2;
        F2jvalue=-F2ivalue;
        Fij=Particules.get(j).position.copy();
        Fij.sub(Particules.get(i).position);
        Fij.normalize();
        F2i=Fij.copy();
        //F2i.normalize();
        F2i=F2i.mult((F2ivalue)/Particules.get(i).masse);
        F2j=Fij.copy();
        //F2j.normalize();
        F2j=F2j.mult(F2jvalue/Particules.get(j).masse);
        Particules.get(i).vitesse.sub(Fi);
        Particules.get(i).acceleration.sub(Fi);
        Particules.get(j).vitesse.add(Fj);
        Particules.get(j).acceleration.add(Fj);
        Particules.get(i).vitesse.sub(F2i);
        Particules.get(i).acceleration.sub(F2i);
        Particules.get(j).vitesse.sub(F2j);
        Particules.get(j).acceleration.sub(F2j);
        //stroke(0, 128, 0);
        //line(Particules.get(i).position.x, Particules.get(i).position.y, Particules.get(i).position.x+Particules.get(i).vitesse.x*10, Particules.get(i).position.y+Particules.get(i).vitesse.y*10);
        //line(Particules.get(i).position.x, Particules.get(i).position.y, Particules.get(i).position.x-Fi.x*1000, Particules.get(i).position.y-Fi.y*1000);
        //ellipse(Particules.get(i).position.x, Particules.get(i).position.y,dlimit,dlimit);
        //stroke(0, 0, 128);
        //line(Particules.get(j).position.x, Particules.get(j).position.y, Particules.get(j).position.x+Particules.get(j).vitesse.x*10, Particules.get(j).position.y+Particules.get(j).vitesse.y*10);
        //line(Particules.get(j).position.x, Particules.get(j).position.y, Particules.get(j).position.x+Fj.x*1000, Particules.get(j).position.y+Fj.y*1000);
        //ellipse(Particules.get(j).position.x, Particules.get(j).position.y,dlimit,dlimit);
        //delay(50);
        if (str(Fivalue)=="NaN" ||str(Fjvalue)=="NaN" ) {
          Particules.get(i).setAge(max_age-1);
          Particules.get(i).look_older();
          Particules.get(j).setAge(max_age-1);
          Particules.get(j).look_older();
        }
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  String message="Framedelay : ";
  framedelay+=int (e);
  framedelay=max(0, framedelay);
  message=message + str(framedelay) + "ms";
  fill(0, 102, 153);
  text(message, 20, 20);
  //fill(0, 102, 153,50);
  //text(Particules.get(i).masse, Particules.get(i).position.x, Particules.get(i).position.y);
}

void mousePressed() {
  debug=!debug;
}

//void mousePressed() {
//  redraw();
//}


//void continu() {
//  if (mousePressed == true) {
//    redraw();
//  }
//}