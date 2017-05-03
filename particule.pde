class particule {
  PVector position;
  float masse;
  int age;
  int radius_evolve=-1;
  float radius;
  PVector vitesse;
  PVector acceleration=new PVector (0, 0);
  float energie;//de max_radius*5*100
  ArrayList<particule> SubParticules=new ArrayList<particule>();
  //PImage image=new PImage();

  particule(int age_min, int age_max, float radius, float vx, float vy, float energie, PVector position) {
    if (position.mag()==0) {
      this.position=new PVector(random(width), random(height));
    }else{
      this.position=new PVector(position.x,position.y);
    }
    this.age=int(random(age_min, age_max));
    this.radius=random(radius);
    //this.masse=pow(this.radius,3)*4/3*PI/5;
    this.masse=pow(this.radius, 3)*4/3*PI*200;
    this.vitesse=new PVector(vx, vy);
    if (energie==-1) {
      this.energie=masse*100;
    }
    //this.image=createImage(this.radius, this.radius, RGB);
  }

  void setRadius(float radius) {
    if (this.radius>1 && this.radius<radius) {
      this.radius=this.radius+this.radius_evolve;
    } else {
      this.radius_evolve=-this.radius_evolve;
      this.radius=this.radius+this.radius_evolve;
    }
  }

  float getRadius() {
    return(this.radius);
  }

  int getAge() {
    return(this.age);
  }

  void setAge(int age) {
    this.age=age;
  }

  void look_older() {
    this.age=this.age+1;
    if (this.age==max_age) {
      this.vitesse.set(0, 0);
      this.masse=0;
    }
  }

  void subparticulescreate(int nb_sub_max, float energie, PVector position) {
    //int max_age=50;
    float max_radius=2;
    float v_max=10;
    int nb_part=int(random(1, nb_sub_max));
    for (int i=0; i<nb_part; i++) {
      float quantum_e=random(energie);
      this.SubParticules.add(new particule(max_age-max_sub_age, max_age, max_radius, random(-v_max, v_max), random(-v_max, v_max), quantum_e,this.position));
      this.SubParticules.get(i).masse=0;
      this.SubParticules.get(i).position.set(position);
      if (i==nb_part-1) {
        this.SubParticules.get(i).energie=energie;
      }
      energie=energie-quantum_e;
    }
  }

  void subparticulesmove() {
    float tempvx;
    float tempvy;
    this.position.add(this.vitesse);
    //this.position.set(max(0,min(this.position.x,width))));
    if (this.position.x+this.radius>width || this.position.x-this.radius<0) {
      tempvx=-this.vitesse.x;
      tempvy=this.vitesse.y;
      this.vitesse.set(tempvx, tempvy);
    }
    if (this.position.y+this.radius>height || this.position.y-this.radius<0) {
      tempvx=this.vitesse.x;
      tempvy=-this.vitesse.y;
      this.vitesse.set(tempvx, tempvy);
    }
  }

  void subparticulesdraw() {
    color from[]={color(255, 0, 0), color(255, 117, 0), color(255, 255, 0), color(127, 255, 0), color(0, 255, 0), color(0, 178, 255), color(28, 0, 255)};
    color to[]={color(255, 117, 0), color(255, 255, 0), color(127, 255, 0), color(0, 255, 0), color(0, 178, 255), color(28, 0, 255), color(71, 0, 143)};
    PVector previous_pos=new PVector();
    for (int i=0; i<this.SubParticules.size(); i++) {
      previous_pos.set(this.SubParticules.get(i).position);
      this.SubParticules.get(i).subparticulesmove();
      int age=this.SubParticules.get(i).getAge();
      int color_idx=int(this.SubParticules.get(i).energie/E_max*7);
      color_idx=min(6, color_idx);
      //stroke(8, 69, 147, (100*age/30));
      stroke(lerpColor(from[color_idx], to[color_idx], 1-(max_age-age)/max_sub_age), min(100, 4*(max_age-age)));
      //strokeWeight((max_age+max_sub_age-age)/max_sub_age*2);
      fill(lerpColor(from[color_idx], to[color_idx], 1-(max_age-age)/max_sub_age), min(100, 4*(max_age-age)));
      //while(this.SubParticules.get(i).getAge()<max_age) {
      ellipse(this.SubParticules.get(i).position.x, this.SubParticules.get(i).position.y, this.SubParticules.get(i).getRadius(), this.SubParticules.get(i).getRadius());
      //line(this.position.x, this.position.y, this.SubParticules.get(i).position.x, this.SubParticules.get(i).position.y);
      line(previous_pos.x, previous_pos.y, this.SubParticules.get(i).position.x, this.SubParticules.get(i).position.y);
      this.SubParticules.get(i).setRadius(2);
      this.SubParticules.get(i).look_older();
      //}
      //this.SubParticules.remove(i);
    }
  }
}