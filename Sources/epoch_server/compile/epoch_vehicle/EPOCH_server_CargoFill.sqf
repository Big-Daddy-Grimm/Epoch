/*
	Author: He-Man - Ignatz-Gaming

    Contributors:

	Description:
	Fill a Cargo Inventory (that is readed out with EPOCH_server_CargoSave before)

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
	https://github.com/EpochModTeam/Epoch/tree/release/Sources/epoch_server/compile/epoch_vehicle/EPOCH_server_CargoFill.sqf
	
    Example:
    [_vehicle, _Inventory] call EPOCH_server_CargoFill;

    Parameter(s):
		_this select 0: OBJ - Storage or Vehicle
        _this select 1: ARRAY - Cargo Items

	Returns:
	NOTHING
*/


params [["_vehicle",objnull],["_items",[]]];
{
	_objType = _forEachIndex;
	_objTypes = _x;
	_objQty = [];
	if (_objType in [1, 2, 3]) then {
		_objTypes = _x select 0;
		_objQty = _x select 1;
	};
	{
		switch _objType do {
			// Weapon cargo
			case 0: {
				if (_x isEqualType []) then {
					if ((count _x) >= 4) then {
						_vehicle addWeaponCargoGlobal[_x deleteAt 0, 1];
						_attachments = [];
						_wMags = false;
						_wMagsArray = [];
						// suppressor, laser, optics, magazines(array), bipods
						{
							// magazines
							if (_x isEqualType []) then{
								_wMags = true;
								_wMagsArray = _x;
							} else {
								// attachments
								if (_x != "") then{
									_attachments pushBack _x;
								};
							};
						} forEach _x;
						// add all attachments to vehicle
						// TODO replace with adding attachments directly to gun (Arma feature dependant)
						{
							_vehicle addItemCargoGlobal[_x, 1];
						} forEach _attachments;
						if (_wMags) then{
							if (_wMagsArray isEqualType [] && (count _wMagsArray) >= 2) then{
								_vehicle addMagazineAmmoCargo[_wMagsArray select 0, 1, _wMagsArray select 1];
							};
						};
					};
				};
			};
			// Magazine cargo
			case 1: {
				_magazineName = _x;
				_magazineSize = _objQty select _forEachIndex;
				if ((_magazineName isEqualType "STRING") && (_magazineSize isEqualType 0)) then {
					_magazineSizeMax = getNumber (configFile >> "CfgMagazines" >> _magazineName >> "count");
					if (_magazineSizeMax >= 1) then {
						// Add full magazines cargo
						_vehicle addMagazineAmmoCargo [_magazineName, floor (_magazineSize / _magazineSizeMax), _magazineSizeMax];
						// Add last non full magazine
						if ((_magazineSize % _magazineSizeMax) > 0) then {
							_vehicle addMagazineAmmoCargo [_magazineName, 1, floor (_magazineSize % _magazineSizeMax)];
						};
					};
				};
			};
			// Backpack cargo
			case 2: {
				if (_x isEqualType "STRING") then {
					_qty = _objQty select _forEachIndex;
					_vehicle addBackpackCargoGlobal [_x, _qty];
				};
			};
			// Item cargo
			case 3: {
				if (_x isEqualType "STRING") then {
					_qty = _objQty select _forEachIndex;
					_vehicle addItemCargoGlobal [_x, _qty];
				};
			};
			// Sub-Containers
			case 4: {
				_type = _x select 0;
				_subContainers = (everycontainer _vehicle) select {(_x select 0)  isequalto _type && magazinesAmmoCargo (_x select 1) isequalto [] && weaponsItemsCargo (_x select 1) isequalto []};
				if !(_subContainers isequalto [])
				then {
					_subContainer = _subContainers select 0 select 1;
					[_subContainer,_x select 1] call EPOCH_server_CargoFill;
				};
			};
		};
	} forEach _objTypes;
} forEach _items;
