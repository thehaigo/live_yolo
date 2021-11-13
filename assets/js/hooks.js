let Hooks = {};
Hooks.Canvas = {
  mounted() {
    let canvas = this.el.firstElementChild;
    let context = canvas.getContext("2d");
    let img = new Image();

    Object.assign(this, {
      canvas,
      context,
    });

    this.handleEvent("draw", (path) => {
      img.src = `data:${path.mime};base64,${path.src}`;
      img.onload = () => {
        let width = img.width;
        let height = img.height;
        canvas.width = width;
        canvas.height = height;
        context.drawImage(img, 0, 0);
      };
    });

    this.handleEvent("detect", (path) => {
      path.detect.objects.forEach((d) => {
        context.fillStyle = "blue";
        context.font = "30px";
        context.textAlign = "left";
        context.textBaseline = "top";
        context.fillText(d.label, d.x, d.y - 10, 20);
        context.strokeStyle = "rgb(0, 0, 255)";
        context.strokeRect(d.x, d.y, d.w, d.h);
      });
    });

    this.handleEvent("remove", () => {
      context.clearRect(0, 0, canvas.width, canvas.height);
      canvas.height = 150;
    });

    this.handleEvent("clip", (path) => {
      let clip = document.getElementById("clip");
      let ctx = clip.getContext("2d");
      const data = path.detect.objects.map((d) => {
        let w = d.w > d.h ? d.w : d.h;
        let h = d.h > d.w ? d.h : d.w;
        clip.width = canvas.width;
        clip.height = canvas.height;
        ctx.clearRect(0, 0, clip.width, clip.height);
        let a = context.getImageData(d.x, d.y, w, h);
        clip.width = w;
        clip.height = h;
        ctx.putImageData(a, 0, 0);
        return { src: clip.toDataURL(), label: d.label };
      });
      this.pushEvent("cliped", data);
    });
  },
};
export default Hooks;
