import React from "react";
import {
  AbsoluteFill,
  Img,
  Sequence,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export type Reel15sProps = {
  hook: string;
  oferta: string;
  cta: string;
  color1: string;
  color2: string;
  foto?: string;
};

export const defaultProps: Reel15sProps = {
  hook: "Você sabia disso?",
  oferta: "30GB Claro · R$ 54,90",
  cta: "Chama no WhatsApp",
  color1: "#C9A84A",
  color2: "#0B0C1F",
  foto: "",
};

const Card: React.FC<{
  text: string;
  bg: string;
  fg: string;
  startFrame: number;
}> = ({ text, bg, fg, startFrame }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const localFrame = frame - startFrame;
  const opacity = interpolate(localFrame, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const scale = spring({
    frame: localFrame,
    fps,
    from: 0.85,
    to: 1,
    config: { damping: 12, stiffness: 100 },
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: bg,
        justifyContent: "center",
        alignItems: "center",
        padding: 80,
      }}
    >
      <div
        style={{
          opacity,
          transform: `scale(${scale})`,
          color: fg,
          fontFamily: "Inter, system-ui, sans-serif",
          fontWeight: 800,
          fontSize: 110,
          textAlign: "center",
          lineHeight: 1.15,
          letterSpacing: -2,
          maxWidth: 920,
        }}
      >
        {text}
      </div>
    </AbsoluteFill>
  );
};

export const Reel15s: React.FC<Reel15sProps> = ({
  hook,
  oferta,
  cta,
  color1,
  color2,
  foto,
}) => {
  const fps = 30;
  const cardFrames = 5 * fps;

  return (
    <AbsoluteFill style={{ backgroundColor: color2 }}>
      {foto ? (
        <AbsoluteFill style={{ opacity: 0.18 }}>
          <Img src={foto} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        </AbsoluteFill>
      ) : null}

      <Sequence from={0} durationInFrames={cardFrames}>
        <Card text={hook} bg={color2} fg={color1} startFrame={0} />
      </Sequence>

      <Sequence from={cardFrames} durationInFrames={cardFrames}>
        <Card text={oferta} bg={color1} fg={color2} startFrame={cardFrames} />
      </Sequence>

      <Sequence from={cardFrames * 2} durationInFrames={cardFrames}>
        <Card text={cta} bg={color2} fg={color1} startFrame={cardFrames * 2} />
      </Sequence>
    </AbsoluteFill>
  );
};
