import React from "react";
import { Composition } from "remotion";
import { Reel15s, defaultProps, Reel15sProps } from "./Reel15s";

export const Root: React.FC = () => {
  return (
    <Composition
      id="reel-15s"
      component={Reel15s}
      durationInFrames={15 * 30}
      fps={30}
      width={1080}
      height={1920}
      defaultProps={defaultProps satisfies Reel15sProps}
    />
  );
};
