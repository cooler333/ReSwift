//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

public typealias DispatchFunction<ActionType> = (ActionType) -> Void
public typealias Middleware<State, ActionType> = (@escaping DispatchFunction<ActionType>, @escaping () -> State?)
    -> (@escaping DispatchFunction<ActionType>) -> DispatchFunction<ActionType>
