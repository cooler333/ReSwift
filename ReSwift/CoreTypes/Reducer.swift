//
//  Reducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

public typealias Reducer<ReducerStateType, ActionType> =
    (_ action: ActionType, _ state: ReducerStateType?) -> ReducerStateType
