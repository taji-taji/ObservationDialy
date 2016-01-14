//
// Generated by CocoaPods-Keys
// on 13/01/2016
// For more information see https://github.com/orta/cocoapods-keys
//

#import <objc/runtime.h>
#import <Foundation/NSDictionary.h>
#import "ObservationdiaryKeys.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation ObservationdiaryKeys

#pragma clang diagnostic pop

+ (BOOL)resolveInstanceMethod:(SEL)name
{
  NSString *key = NSStringFromSelector(name);
  NSString * (*implementation)(ObservationdiaryKeys *, SEL) = NULL;

  if ([key isEqualToString:@"flurryAPIKey"]) {
    implementation = _podKeysad95ee8646f8589e51050924ccd51a22;
  }

  if (!implementation) {
    return [super resolveInstanceMethod:name];
  }

  return class_addMethod([self class], name, (IMP)implementation, "@@:");
}

static NSString *_podKeysad95ee8646f8589e51050924ccd51a22(ObservationdiaryKeys *self, SEL _cmd)
{
  
    
      char cString[21] = { ObservationdiaryKeysData[118], ObservationdiaryKeysData[367], ObservationdiaryKeysData[318], ObservationdiaryKeysData[455], ObservationdiaryKeysData[151], ObservationdiaryKeysData[603], ObservationdiaryKeysData[52], ObservationdiaryKeysData[738], ObservationdiaryKeysData[689], ObservationdiaryKeysData[585], ObservationdiaryKeysData[66], ObservationdiaryKeysData[638], ObservationdiaryKeysData[30], ObservationdiaryKeysData[400], ObservationdiaryKeysData[99], ObservationdiaryKeysData[108], ObservationdiaryKeysData[266], ObservationdiaryKeysData[675], ObservationdiaryKeysData[769], ObservationdiaryKeysData[431], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}


static char ObservationdiaryKeysData[778] = "Abk3t4/oEQZKibZIRR0CRQFMH4UloZKCzgUwSDGHXVVDhWckz3IeHFFr2BqZzxw528GBIommUFQhrWeGrbfHn88U7V/ipdUvcukRq324lbX/DU0lu5OLazV7JprHxkQEWtYXSTe1ZDaa/d018By52PQCVg2LF5dap37WOwxO3HXeaBv78c7Np0Xr+xfcWkg3QQENK1szTrULk+lTXQMsx8c1uqdtFlX1DfoeLLeyIn/z8GugveRUNu4kPxMpHzq2QgOIdFXlwGDq46oc172Zz+76cM7bioKM2oRYI3B539+r48TsGyO5YW/Bin75AHRuALkb2D4b1BpQUcSiKolU4NSd/Qe9bT905nFV9+ReyylwVaWQlBC4Ie+nuOcrhul42mubY+5IRBrcFWytVW+6+9qL7T3ppnCzFfbt0lKSeJgSOvb646Mr2XAXZ+FJaze0yF59L8GVBm80eNmSKdUYZ9zujzrs/urycv9gEn5oyQIWRd2gtRubJX0yt/xZApH1JIaGNZ7jleiy6mkFUf96qOkanO4Jd9f3JHgUZCIjqcuwLgOQIYR9mBNhIzan6KTFJwS3X6GWI8sK8l2LDy2tzh/WavJHLgNeIpz04MJenwfTFOsqJ6Ijww9tfC+yX1QTKBsavMCbI6ZRx5rgPvHzFpRbwNRv6AxKsgwDSkRSnKnhr4aAQWGEcZ4nTgIZ+EEfMt9HTyPi3O+J9+o2usNS+DXVhenKNIF5ks9VeFR+sOPKsoPbEoS35mfSboc+IpPhcWIXxw==\\\"";

- (NSString *)description
{
  return [@{
            @"flurryAPIKey": self.flurryAPIKey,
  } description];
}

- (id)debugQuickLookObject
{
  return [self description];
}

@end