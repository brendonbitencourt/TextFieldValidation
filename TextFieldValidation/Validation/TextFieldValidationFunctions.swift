//
//  TextFieldValidationFunctions.swift
//  TextFieldValidation
//
//  Created by Brendon Bitencourt Braga on 2021-03-07.
//

import Foundation

class TextFieldValidationFunctions {
    static func email(_ text: String?) -> TextFieldValidationType? {
        
        let error = TextFieldValidationType.email
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid { return error }
        
        return nil
    }
    
    static func required(_ text: String?) -> TextFieldValidationType? {
        
        let error = TextFieldValidationType.required
        let regEx = "^.{1,}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid { return error }
        
        return nil
    }
    
    static func maxCharacters(_ text: String?, _ number: Int) -> TextFieldValidationType? {
        
        let error = TextFieldValidationType.maxCharacters(num: number)
        let regEx = "^.{0,\(String(number))}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid { return error }
        
        return nil
    }
    
    static func customRegex(_ text: String?, _ regex: String, _ key: String) -> TextFieldValidationType? {
        
        let error = TextFieldValidationType.customRegex(regex: regex, key: key)
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid { return error }
        
        return nil
    }
}
