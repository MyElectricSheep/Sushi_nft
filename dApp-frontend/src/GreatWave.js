import React, { useRef } from "react";
import "./GreatWave.css";

const GreatWave = ({ children }) => {
  const box = useRef();
  const bg = useRef();
  const waveTop = useRef();
  const waveRight = useRef();
  const waveBottom = useRef();
  const waveBottomRight = useRef();

  const parallax = (event) => {
    const layers = [bg, waveTop, waveRight, waveBottom, waveBottomRight];
    layers.forEach(({ current: layer }) => {
      event.preventDefault();
      let point = {};

      if (event.targetTouches) {
        point.x = event.targetTouches[0].clientX;
        point.y = event.targetTouches[0].clientY;
      } else {
        point.x = event.clientX;
        point.y = event.clientY;
      }
      const speed = layer.dataset.speed;
      const x = (box.current.offsetWidth - point.x * speed) / 100;
      const y = (box.current.offsetWidth - point.y * speed) / 100;
      layer.style.transform = `translate(${x}px, ${y}px)`;
    });
  };

  return (
    <div
      id="box"
      ref={box}
      onMouseMove={parallax}
      onTouchStart={parallax}
      onTouchMove={parallax}
    >
      <div className="bg layer" data-speed="1" ref={bg}></div>
      <div className="wave-top layer" data-speed="-10" ref={waveTop}></div>
      <div className="wave-right layer" data-speed="-1" ref={waveRight}></div>
      <div className="wave-bottom layer" data-speed="6" ref={waveBottom}></div>
      <div
        className="wave-bottom-right layer"
        data-speed="1"
        ref={waveBottomRight}
      ></div>
      <div className="app-container">{children}</div>
    </div>
  );
};

export default GreatWave;
