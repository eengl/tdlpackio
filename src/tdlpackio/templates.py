from dataclasses import dataclass, field
import datetime


_section_attrs = {0:['edition'],
                  1:['sectionFlags','year','month','day','hour','minute','refDate',
                     'id1','id2','id3','id4','id','leadTime','leadTimeMinutes',
                     'decScaleFactor','binScaleFactor','lengthOfPlainLanguage',
                     'plainLanguage','type'],
                  2:[],
                  4:['packingFlags','numberOfPackedValues','primaryMissingValue',
                     'secondaryMissingValue','overallMinValue','numberOfGroups']}


class Stations:
    def __get__(self, obj, objtype=None):
        return obj._stations
    def __set__(self, obj, value):
        obj.numberOfStations = len(value)
        obj._stations = value

class NumberOfStations:
    def __get__(self, obj, objtype=None):
        return obj._numberOfStations
    def __set__(self, obj, value):
        if obj.stations is None:        
            obj._numberOfStations = value
        else:
            raise AttributeError("cannot change station count if stations exist.")

# --------------------------------------------------------------------------------------
# Section 0
# --------------------------------------------------------------------------------------
class Edition:
    """
    """
    def __get__(self, obj, objtype=None):
        return obj.is0[2]
    def __set__(self, obj, value):
        pass


# --------------------------------------------------------------------------------------
# Section 1
# --------------------------------------------------------------------------------------
class SectionFlags:
    def __get__(self, obj, objtype=None):
        return f'{obj.is1[1]:08b}'
    def __set__(self, obj, value):
        obj.is1[1] = value


class Year:
    def __get__(self, obj, objtype=None):
        return obj.is1[2]
    def __set__(self, obj, value):
        obj.is1[2] = value
        obj.refDate = (value*1000000)+(obj.month*10000)+(obj.day*100)+obj.hour


class Month:
    def __get__(self, obj, objtype=None):
        return obj.is1[3]
    def __set__(self, obj, value):
        obj.is1[3] = value
        obj.refDate = (obj.year*1000000)+(value*10000)+(obj.day*100)+obj.hour


class Day:
    def __get__(self, obj, objtype=None):
        return obj.is1[4]
    def __set__(self, obj, value):
        obj.is1[4] = value
        obj.refDate = (obj.year*1000000)+(obj.month*10000)+(value*100)+obj.hour


class Hour:
    def __get__(self, obj, objtype=None):
        return obj.is1[5]
    def __set__(self, obj, value):
        obj.is1[5] = value
        obj.refDate = (obj.year*1000000)+(obj.month*10000)+(obj.day*100)+value


class Minute:
    def __get__(self, obj, objtype=None):
        return obj.is1[6]
    def __set__(self, obj, value):
        obj.is1[6] = value


class RefDate:
    def __get__(self, obj, objtype=None):
        return obj.is1[7]
    def __set__(self, obj, value):
        obj.is1[7] = value
        _y = int(str(value)[0:4])
        _m = int(str(value)[4:6])
        _d = int(str(value)[6:8])
        _h = int(str(value)[8:10])
        if _y != obj.year: obj.year = _y
        if _m != obj.month: obj.month = _m
        if _d != obj.day: obj.day = _d
        if _h != obj.hour: obj.hour = _h


class VariableID1:
    def __get__(self, obj, objtype=None):
        return obj.id[0]
    def __set__(self, obj, value):
        obj.is1[8] = value
        obj.is1[14] = int(str(value)[-2:])


class VariableID2:
    def __get__(self, obj, objtype=None):
        return obj.id[1]
    def __set__(self, obj, value):
        obj.is1[9] = value


class VariableID3:
    def __get__(self, obj, objtype=None):
        return obj.id[2]
    def __set__(self, obj, value):
        obj.is1[10] = value


class VariableID4:
    def __get__(self, obj, objtype=None):
        return obj.id[3]
    def __set__(self, obj, value):
        obj.is1[11] = value


class VariableID:
    def __get__(self, obj, objtype=None):
        return obj.is1[8:12]
    def __set__(self, obj, value):
        obj.id = value
        if value[0] != obj.id1: obj.id1 = value[0]
        if value[1] != obj.id2: obj.id2 = value[1]
        if value[2] != obj.id3: obj.id3 = value[2]
        if value[3] != obj.id4: obj.id4 = value[3]


class LeadTime:
    def __get__(self, obj, objtype=None):
        return obj.is1[12]
    def __set__(self, obj, value):
        obj.is1[12] = value
        lt = str(obj.id3.zfill(9))[-3:]
        if value != lt: obj.id3 = int(str(obj.id3)[:6]+str(value).zfill(3))


class LeadTimeMinutes:
    def __get__(self, obj, objtype=None):
        return obj.is1[13]
    def __set__(self, obj, value):
        obj.is1[13] = value


class ModelID:
    def __get__(self, obj, objtype=None):
        return obj.is1[14]
    def __set__(self, obj, value):
        obj.is1[14] = value
        dd = str(obj.id1.zfill(9))[-2:]
        if value != dd: obj.id1 = int(str(obj.id1)[:7]+str(value).zfill(2))


class ModelSequenceID:
    def __get__(self, obj, objtype=None):
        return obj.is1[15]
    def __set__(self, obj, value):
        obj.is1[15] = value


class DecScaleFactor:
    def __get__(self, obj, objtype=None):
        return obj.is1[16]
    def __set__(self, obj, value):
        obj.is1[16] = value


class BinScaleFactor:
    def __get__(self, obj, objtype=None):
        return obj.is1[17]
    def __set__(self, obj, value):
        obj.is1[17] = value


class LengthOfPlainLanguage:
    def __get__(self, obj, objtype=None):
        return obj.is1[21]
    def __set__(self, obj, value):
        pass


class PlainLanguage:
    def __get__(self, obj, objtype=None):
        return ''.join([chr(i) for i in obj.is1[22:]])
    def __set__(self, obj, value):
        for n,s in enumerate(value[:obj.is1[21]]):
            obj.is1[22+n] = np.int32(ord(s))


# --------------------------------------------------------------------------------------
# Section 2
# --------------------------------------------------------------------------------------
class MapProjection:
    def __get__(self, obj, objtype=None):
        return obj.is2[1]
    def __set__(self, obj, value):
        pass


class Nx:
    def __get__(self, obj, objtype=None):
        return obj.is2[2]
    def __set__(self, obj, value):
        pass


class Ny:
    def __get__(self, obj, objtype=None):
        return obj.is2[3]
    def __set__(self, obj, value):
        pass


class LatitudeLowerLeft:
    def __get__(self, obj, objtype=None):
        return obj.is2[4]*1e-4
    def __set__(self, obj, value):
        obj.is2[4] = value*1e+4


class LongitudeLowerLeft:
    def __get__(self, obj, objtype=None):
        return obj.is2[5]*1e-4
    def __set__(self, obj, value):
        obj.is2[5] = value*1e+4


class OrientationLongitude:
    def __get__(self, obj, objtype=None):
        return obj.is2[6]*1e-4
    def __set__(self, obj, value):
        obj.is2[6] = value*1e+4


class GridLength:
    def __get__(self, obj, objtype=None):
        return obj.is2[7]*1e-6
    def __set__(self, obj, value):
        obj.is2[7] = value*1e+6


class StandardLatitude:
    def __get__(self, obj, objtype=None):
        return obj.is2[8]*1e-4
    def __set__(self, obj, value):
        obj.is2[8] = value*1e+4


@dataclass(init=False)
class GridDefinitionSection():
    mapProjection: int = field(init=False, repr=False, default=MapProjection())
    nx: int = field(init=False, repr=False, default=Nx())
    ny: int = field(init=False, repr=False, default=Ny())
    latitudeLowerLeft: float = field(init=False, repr=False, default=LatitudeLowerLeft())
    longtiudeLowerLeft: float = field(init=False, repr=False, default=LongitudeLowerLeft())
    orientationLongitude: float = field(init=False, repr=False, default=OrientationLongitude())
    gridLength: float = field(init=False, repr=False, default=GridLength())
    standardLatitude: float = field(init=False, repr=False, default=StandardLatitude())
    @classmethod
    @property
    def _attrs(cls):
        return list(cls.__dataclass_fields__.keys())


# --------------------------------------------------------------------------------------
# Section 4
# --------------------------------------------------------------------------------------
class PackingFlags:
    def __get__(self, obj, objtype=None):
        return f'{obj.is4[1]:08b}'
    def __set__(self, obj, value):
        pass


class NumberOfPackedValues:
    def __get__(self, obj, objtype=None):
        return obj.is4[2]
    def __set__(self, obj, value):
        pass


class PrimaryMissingValue:
    def __get__(self, obj, objtype=None):
        return obj.is4[3]
    def __set__(self, obj, value):
        pass


class SecondaryMissingValue:
    def __get__(self, obj, objtype=None):
        return obj.is4[4]
    def __set__(self, obj, value):
        pass


class OverallMinValue:
    def __get__(self, obj, objtype=None):
        return obj.is4[5]
    def __set__(self, obj, value):
        pass


class NumberOfGroups:
    def __get__(self, obj, objtype=None):
        return obj.is4[6]
    def __set__(self, obj, value):
        pass