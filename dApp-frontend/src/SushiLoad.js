import React, { useEffect } from "react";
import { gsap, Power4, Back } from "gsap/all";
import "./styles/SushiLoad.css";

export default function SushiLoad() {
  useEffect(() => {
    let beginAnimation = gsap.timeline();
    beginAnimation
      .from(".sushi-container", 3, {
        y: -200,
        ease: Back.easeOut,
      })
      .to(".chopstick-container", 1.5, { top: 0 }, 1.5)
      .to(".chopstick1", 2, { rotation: 10 }, 3.5)
      .to(".chopstick2", 2, { rotation: -10 }, 3.5)
      .to(".shine-left", 0.5, { left: "36.3%" }, 4.2)
      .to(".shine-right", 0.5, { left: "45.5%" }, 4.2)
      .to(".mouth", 0.5, { borderRadius: "90% 90% 10% 10%" }, 4.2)
      .to(
        ".shine-left",
        0.5,
        { left: "35%", top: "68.8%", width: "16px", height: "16px" },
        5.2
      )
      .to(
        ".shine-right",
        0.5,
        { left: "44%", top: "69.8%", width: "16px", height: "16px" },
        5.2
      )
      .to(".roll", 3, { animation: "shake 0.5s 3" }, 5.7)
      .to(".sushi-container", 0.6, { ease: Power4.easeOut, y: -600 }, 6.7)
      .to(".repeat", 4, { animation: "fade-in 3s forwards" }, 7.5);

    const intervalId = setInterval(() => {
      beginAnimation.restart();
    }, 9000);

    return () => clearInterval(intervalId);
  }, []);

  return (
    <div className="sushi-container">
      <div className="chopstick-container">
        <div className="chopstick1"></div>
        <div className="chopstick2"></div>
      </div>
      <div className="roll">
        <div className="rice"></div>
        <div className="seaweed"></div>
        <div className="salmon"></div>
        <div className="eye-left"></div>
        <div className="shine-left"></div>
        <div className="eye-right"></div>
        <div className="shine-right"></div>
        <div className="mouth"></div>
        <div className="tongue"></div>
      </div>
    </div>
  );
}
